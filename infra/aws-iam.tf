# Resources from EKS Cluster
resource "aws_iam_role" "aws-iam-eks" {
  name = "iamr-role-eks-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "aws-iam-eks-cluster" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.aws-iam-eks.name
}

resource "aws_iam_role_policy_attachment" "aws-iam-eks-service" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.aws-iam-eks.name
}

# Resources from Nodes
resource "aws_iam_role" "aws-iam-eks-nodes" {
  name = "iamr-role-eks-nodes"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "aws-iam-eks-worker" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.aws-iam-eks-nodes.name
}

resource "aws_iam_role_policy_attachment" "aws-iam-eks-cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.aws-iam-eks-nodes.name
}

resource "aws_iam_role_policy_attachment" "aws-iam-eks-registry" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.aws-iam-eks-nodes.name
}

resource "aws_iam_role_policy_attachment" "aws-iam-eks-ssmmanaged" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.aws-iam-eks-nodes.name
}

resource "aws_iam_role_policy_attachment" "aws-iam-eks-cloudwatch" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
  role       = aws_iam_role.aws-iam-eks-nodes.name
}

resource "aws_iam_role_policy_attachment" "aws-iam-eks-s3" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.aws-iam-eks-nodes.name
}

data "aws_iam_policy_document" "aws-cluster-auto-scaler-policy-document" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "aws-cluster-auto-scaler-policy" {
  name   = "iam-cluster-auto-scaler-policy-${var.cluster-name}"
  policy = data.aws_iam_policy_document.aws-cluster-auto-scaler-policy-document.json
}

resource "aws_iam_role_policy_attachment" "aws-cluster-auto-scaler-attachment" {
  policy_arn = aws_iam_policy.aws-cluster-auto-scaler-policy.arn
  role      = aws_iam_role.aws-iam-eks-nodes.name
}

data "aws_iam_policy_document" "aws-ingress-policy-document" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "acm:DescribeCertificate",
      "acm:ListCertificates",
      "acm:GetCertificate",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CreateSecurityGroup",
      "ec2:CreateTags",
      "ec2:DeleteTags",
      "ec2:DeleteSecurityGroup",
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeAddresses",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceStatus",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeTags",
      "ec2:DescribeVpcs",
      "ec2:ModifyInstanceAttribute",
      "ec2:ModifyNetworkInterfaceAttribute",
      "ec2:RevokeSecurityGroupIngress",
      "elasticloadbalancing:AddListenerCertificates",
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:CreateListener",
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:CreateRule",
      "elasticloadbalancing:CreateTargetGroup",
      "elasticloadbalancing:DeleteListener",
      "elasticloadbalancing:DeleteLoadBalancer",
      "elasticloadbalancing:DeleteRule",
      "elasticloadbalancing:DeleteTargetGroup",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:DescribeListenerCertificates",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeLoadBalancerAttributes",
      "elasticloadbalancing:DescribeRules",
      "elasticloadbalancing:DescribeSSLPolicies",
      "elasticloadbalancing:DescribeTags",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTargetGroupAttributes",
      "elasticloadbalancing:DescribeTargetHealth",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:ModifyLoadBalancerAttributes",
      "elasticloadbalancing:ModifyRule",
      "elasticloadbalancing:ModifyTargetGroup",
      "elasticloadbalancing:ModifyTargetGroupAttributes",
      "elasticloadbalancing:RegisterTargets",
      "elasticloadbalancing:RemoveListenerCertificates",
      "elasticloadbalancing:RemoveTags",
      "elasticloadbalancing:SetIpAddressType",
      "elasticloadbalancing:SetSecurityGroups",
      "elasticloadbalancing:SetSubnets",
      "elasticloadbalancing:SetWebACL",
      "iam:CreateServiceLinkedRole",
      "iam:GetServerCertificate",
      "iam:ListServerCertificates",
      "cognito-idp:DescribeUserPoolClient",
      "waf-regional:GetWebACLForResource",
      "waf-regional:GetWebACL",
      "waf-regional:AssociateWebACL",
      "waf-regional:DisassociateWebACL",
      "waf:GetWebACL",
      "tag:GetResources",
      "tag:TagResources",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "aws-ingress-policy" {
  name   = "iam-ingress-policy-${var.cluster-name}"
  policy = data.aws_iam_policy_document.aws-ingress-policy-document.json
}

resource "aws_iam_role_policy_attachment" "aws-ingress-policy-attachment" {
  policy_arn = aws_iam_policy.aws-ingress-policy.arn
  role      = aws_iam_role.aws-iam-eks-nodes.name
}

data "aws_iam_policy_document" "aws-external-dns-policy-document" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "aws-external-dns-policy" {
  name   = "iam-external-dns-policy-${var.cluster-name}"
  policy = data.aws_iam_policy_document.aws-external-dns-policy-document.json
}

resource "aws_iam_role_policy_attachment" "aws-external-dns-policy-attachment" {
  policy_arn = aws_iam_policy.aws-external-dns-policy.arn
  role      = aws_iam_role.aws-iam-eks-nodes.name
}

resource "aws_iam_instance_profile" "aws-iam-eks-node-profile" {
  name = "iam-eks-instance-profile-${var.cluster-name}"
  role = aws_iam_role.aws-iam-eks-nodes.name
}
