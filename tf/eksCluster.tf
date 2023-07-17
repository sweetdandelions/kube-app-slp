# EKS cluster configuration
resource "aws_eks_cluster" "eks_groudplex_01" {
  name     = var.eks_cluster_name
  role_arn = aws_iam_role.eksClusterRole.arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids         = aws_subnet.private_subnet.*.id
    security_group_ids = [aws_security_group.Cluster_SG.id]
  }

  # Ensures that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSServicePolicy
  ]

  tags = {
    Name = "Groundplex K8S cluster",
  }
}

# Worker Nodes configuration
resource "aws_eks_node_group" "eks_nodes" {
  cluster_name    = aws_eks_cluster.eks_groudplex_01.name
  node_group_name = "Workers"
  node_role_arn   = aws_iam_role.eksNodesRole.arn
  subnet_ids      = aws_subnet.private_subnet.*.id

  scaling_config {
    desired_size = 1
    max_size     = 4
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  ami_type       = var.ami_type
  instance_types = var.cluster_instance
  capacity_type  = var.capacity

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]

  provisioner "local-exec" {
    when = create
    command = "./Deployments.sh"
    interpreter = [ "sh" ]
    working_dir = "${path.module}/../scripts/"
  }

  provisioner "local-exec" {
    when = destroy
    command = "kubectl delete svc snaplogic-snaplogic-snaplex-regular -n snaplogic"
  }

  tags = {
    "Name" = "Groundplex K8S node"
    "k8s.io/cluster-autoscaler/enabled" = "true"
    "k8s.io/cluster-autoscaler/eks_groudplex_01" = "owned"

  }
}

resource "null_resource" "kubeconfig" {
  depends_on = [
    aws_eks_cluster.eks_groudplex_01
  ]

  provisioner "local-exec" {
    command = "aws eks --region ${var.region} update-kubeconfig --name ${var.eks_cluster_name}"
  }
}

# aws-ebs-csi-driver
resource "aws_eks_addon" "addons" {
  for_each          = { for addon in var.addons : addon.name => addon }
  cluster_name      = aws_eks_cluster.eks_groudplex_01.id
  addon_name        = each.value.name
  addon_version     = each.value.version
  resolve_conflicts_on_create = "OVERWRITE"

  depends_on = [ aws_eks_cluster.eks_groudplex_01 ]
}