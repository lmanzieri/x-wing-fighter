locals {
   node-userdata = <<EOF
               #!/bin/bash
               set -o xtrace
               /etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.aws-eks.endpoint}' \
                                     --b64-cluster-ca '${aws_eks_cluster.aws-eks.certificate_authority.0.data}' '${var.cluster-name}-${var.environment}'
               yum update -y && yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
             EOF
  k8s-version = "1.16"
}

data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${local.k8s-version}-v*"]
  }
  most_recent = true
  owners      = ["602401143452"]
}

resource "aws_cloudwatch_log_group" "eks-cloudwatch" {
  name              = "/aws/eks/${var.cluster-name}-${var.environment}/cluster"
  retention_in_days = 7
}

resource "aws_eks_cluster" "aws-eks" {
  name                      = "${var.cluster-name}-${var.environment}"
  role_arn                  = aws_iam_role.aws-iam-eks.arn
  version                   = local.k8s-version
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  vpc_config {
    subnet_ids              = data.aws_subnet_ids.getsubnets.ids
    security_group_ids      = [aws_security_group.aws-eks-securitygroup.id]
    endpoint_private_access = "true"
    # endpoint_public_access  = "false"
  }
  depends_on = [
    aws_iam_role_policy_attachment.aws-iam-eks-cluster,
    aws_iam_role_policy_attachment.aws-iam-eks-service,
    aws_cloudwatch_log_group.eks-cloudwatch,
    aws_security_group.aws-eks-securitygroup
  ]
}

resource "aws_eks_node_group" "aws-eks-ng" {
 cluster_name      = aws_eks_cluster.aws-eks.name
 node_group_name   = "${var.cluster-name}-ng"
 instance_types    = ["t3.medium"]
 node_role_arn     = aws_iam_role.aws-iam-eks-nodes.arn
 subnet_ids        = data.aws_subnet_ids.getsubnets.ids
 labels            = {}
 tags = {
   "Name" = "node-${aws_eks_cluster.aws-eks.name}"
 }
 scaling_config {
   desired_size = 2
   max_size     = 4
   min_size     = 2
 }
 lifecycle {
   ignore_changes = [
     scaling_config
   ]
 }
 depends_on = [
   aws_iam_role_policy_attachment.aws-iam-eks-worker,
   aws_iam_role_policy_attachment.aws-iam-eks-cni,
   aws_iam_role_policy_attachment.aws-iam-eks-registry,
   aws_eks_cluster.aws-eks

 ]
}

resource "aws_launch_configuration" "aws-launch-nodes" {
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.aws-iam-eks-node-profile.name
  image_id                    = data.aws_ami.eks-worker.id
  instance_type               = "t3.medium"
  name_prefix                 = "node-${var.cluster-name}"
  security_groups             = [aws_security_group.aws-eks-securitygroup.id]
  user_data_base64            = base64encode(local.node-userdata)
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_template" "aws-launch-template-core" {
  name          = var.cluster-name
  image_id      = data.aws_ami.eks-worker.id
  instance_type = "t3.medium"
  user_data     = base64encode(local.node-userdata)
  iam_instance_profile {
    name = aws_iam_instance_profile.aws-iam-eks-node-profile.name
  }
  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.aws-eks-securitygroup.id]
  }
}

resource "aws_autoscaling_group" "aws-autoscaling-group-nodes" {
  # launch_configuration = aws_launch_configuration.aws-launch-nodes.id
  desired_capacity    = 2
  max_size            = 4
  min_size            = 1
  name                = "nodes-${var.cluster-name}"
  vpc_zone_identifier = data.aws_subnet_ids.getsubnets.ids
  //  target_group_arns    = [aws_lb_target_group.node-target-group.arn]
  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.aws-launch-template-core.id
      }
    }
    instances_distribution {
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 0
      spot_allocation_strategy                 = "capacity-optimized"
    }
  }
  //Evita atualizar o cluster quando gerenciado pelo "ClusterAutoscaling"
  lifecycle {
    ignore_changes = [desired_capacity, mixed_instances_policy.0.launch_template.0.override]
  }
  tag {
    key                 = "Name"
    value               = "node-${var.cluster-name}-${var.environment}"
    propagate_at_launch = true
  }
  tag {
    key                 = "kubernetes.io/cluster/${var.cluster-name}-${var.environment}"
    value               = "owned"
    propagate_at_launch = true
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/${var.cluster-name}-${var.environment}"
    value               = "owned"
    propagate_at_launch = true
  }
  tag {
    key                 = " eks:cluster-name"
    value               = "${var.cluster-name}-${var.environment}"
    propagate_at_launch = true
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/enabled"
    value               = "true"
    propagate_at_launch = true
  }
  tag {
    key                 = "customer"
    value               = "rubberduck"
    propagate_at_launch = true
  }
}

output "eks-foundation-endpoint" {
  value = aws_eks_cluster.aws-eks-foundation.endpoint
}

output "eks-foundation-arn" {
  value = aws_eks_cluster.aws-eks-foundation.arn
}

output "eks-foundation-certificate_authority" {
  value = aws_eks_cluster.aws-eks-foundation.certificate_authority.0.data
}
