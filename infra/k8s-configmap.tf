#resource "kubernetes_config_map" "aws-auth" {
#  metadata {
#    name      = "aws-auth"
#    namespace = "kube-system"
#  }
#  data = {
#    mapRoles = <<EOF
#- rolearn: ${aws_iam_role.aws-iam-eks-nodes.arn}
#  username: system:node:{{EC2PrivateDNSName}}
# groups:
#    - system:bootstrappers
#    - system:nodes
#    - system:node-proxier
#   EOF

#    mapUsers = <<EOF
#- userarn: arn:aws:sts::176663549986:assumed-role/devopsrole
#  username: *
#  groups:
#   - system:masters
#   EOF
#  }
#  depends_on = [
#   aws_eks_cluster.aws-eks,
#   aws_autoscaling_group.aws-autoscaling-group-nodes
#  ]
#}
