data "aws_caller_identity" "getidentity" {}

data "aws_region" "getregion" {}

data "aws_vpcs" "getvpc" {
  tags = {
    Name = "${var.vpc-name}"
  }
}

data "aws_subnet_ids" "getsubnets" {
  vpc_id = element(tolist(data.aws_vpcs.getvpc.ids), 0)

  tags = {
    Name = "*"
  }
}

data "aws_eks_cluster_auth" "cluster_auth" {
  name = "${var.cluster-name}-${var.environment}"
}

output "getcluster_token" {
  value = "${data.aws_eks_cluster_auth.cluster_auth.token}"
}

output "getidentity_id" {
  value = "${data.aws_caller_identity.getidentity.account_id}"
}

output "getidentity_arn" {
  value = "${data.aws_caller_identity.getidentity.arn}"
}

output "getidentity_user" {
  value = "${data.aws_caller_identity.getidentity.user_id}"
}

output "getregion_name" {
  value = "${data.aws_region.getregion.name}"
}

output "getvpc-output" {
  value = "${data.aws_vpcs.getvpc.ids}"
}

output "getsubnets-output" {
  value = "${data.aws_subnet_ids.getsubnets.ids}"
}