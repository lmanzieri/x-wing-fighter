resource "kubernetes_namespace" "rubberduck" {
  metadata {
    name = "rubberduck"
  }

 depends_on = [
   aws_eks_cluster.aws-eks
  #  aws_autoscaling_group.aws-autoscaling-group-nodes
 ]
 
}