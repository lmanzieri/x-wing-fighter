terraform {
  required_version = ">= 0.12"
  required_providers {
    aws        = "~> 2.8"
    kubernetes = "~> 1.10"
    local      = "~> 1.3"
    template   = "~> 2.1"
    helm       = "~> 0.10"
    external   = "~> 1.2"
    tls        = "~> 2.1"
    archive    = "~> 1.2"
    random     = "~> 2.2"
  }
}

provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.aws-eks.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.aws-eks.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster_auth.token
    load_config_file       = false
  }
  service_account = "tiller"
  install_tiller  = true
  init_helm_home  = true
  debug           = true
}

provider "kubernetes" {
  host                   = aws_eks_cluster.aws-eks.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.aws-eks.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster_auth.token
  load_config_file       = false
}