resource "aws_security_group" "aws-eks-securitygroup" {
  name        = "${var.cluster-name}-sg"
  description = "Managed by Terraform - communication with worker nodes"
  vpc_id      = element(tolist(data.aws_vpcs.getvpc.ids), 0)

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "kubernetes.io/cluster/${var.cluster-name}" = "owned"
    "security-fms" : "ignore"
  }

}