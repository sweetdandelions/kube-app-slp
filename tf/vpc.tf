# AWS VPC resource
resource "aws_vpc" "main-kube_vpc" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"

  # Enabled, so worker nodes can register with the cluster
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    "Name"                                          = "Groundplex VPC"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
  }
}