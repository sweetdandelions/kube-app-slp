/*#---------------------------------------------------------------------#
#                        Nodes security group                         #
#---------------------------------------------------------------------#
resource "aws_security_group" "WorkerNodes_SG" {
  name        = "WorkerNodes_SG"
  description = "Security group for all nodes in the cluster"
  vpc_id      = aws_vpc.main-kube_vpc.id

  tags = {
    "Name"                                          = "Node SG"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
  }
}

resource "aws_security_group_rule" "workers_self_ingress" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = aws_security_group.WorkerNodes_SG.id
  source_security_group_id = aws_security_group.WorkerNodes_SG.id
  type                     = "ingress"
}

resource "aws_security_group_rule" "workers_control_plane_ingress" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.WorkerNodes_SG.id
  source_security_group_id = aws_security_group.Cluster_SG.id
  type                     = "ingress"
}

resource "aws_security_group_rule" "workers_hpa_control_plane_ingress" {
  description              = "Allow HPA to receive communication from the cluster control plane"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.WorkerNodes_SG.id
  source_security_group_id = aws_security_group.Cluster_SG.id
  type                     = "ingress"
}

resource "aws_security_group_rule" "control_plane_to_node_egress" {
  description              = "Allow the cluster control plane to communicate with worker Kubelet and pods"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.Cluster_SG.id
  source_security_group_id = aws_security_group.WorkerNodes_SG.id
  type                     = "egress"
}

resource "aws_security_group_rule" "SSH_nat_ingress" {
  cidr_blocks       = var.num_public_sub
  description       = "Allow the cluster control plane to communicate with worker Kubelet and pods"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.WorkerNodes_SG.id
  type              = "ingress"
}*/

#---------------------------------------------------------------------#
#                       Cluster security group                        #
#---------------------------------------------------------------------#

resource "aws_security_group" "Cluster_SG" {
  name        = "Cluster_SG"
  description = "Communicate with worker nodes"
  vpc_id      = aws_vpc.main-kube_vpc.id

  tags = {
    "Name" = "Cluster security group"
  }
}

resource "aws_security_group_rule" "cluster_workstation_ingress_443" {
  description       = "Allow workstation to communicate with the cluster API Server"
  cidr_blocks       = [local.workstation-external-cidr]
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  security_group_id = aws_security_group.Cluster_SG.id
  type              = "ingress"
}

resource "aws_security_group_rule" "cluster_egress" {
  description       = "Allow cluster communication with worker nodes"
  cidr_blocks       = ["0.0.0.0/0"]
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  security_group_id = aws_security_group.Cluster_SG.id
  type              = "egress"
}