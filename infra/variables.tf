variable "region" {
  type    = string
  default = "us-east-1"
}

variable "environment" {
  description   = "eks environment"
  default       = "dev"
}

variable "vpc-name" {
  description   = "vpc name from environment"
  default       = "*"
}

variable "cluster-name" {
  description   = "name from eks cluster to applications"
  default = "eks-rubberduck"
  type    = string
}

variable "ingress-url" {
    type = map(string)
    default = {
      dev   =   "dev.aws.rubberduck.com"
      hom   =   "hom.aws.rubberduck.com"
      prd   =   "prd.aws.rubberduck.com"
    }
  }
