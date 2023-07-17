# Amazon EKS cluster IAM role
resource "aws_iam_role" "eksClusterRole" {
  name               = "eksClusterRole"
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

# Attach the required IAM policies to the Cluster role
resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  role       = aws_iam_role.eksClusterRole.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
  role       = aws_iam_role.eksClusterRole.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

# Amazon EKS worker nodes IAM role
resource "aws_iam_role" "eksNodesRole" {
  name               = "eksNodesRole"
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

# Attach the required IAM policies to the Nodes role
resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  role       = aws_iam_role.eksNodesRole.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  role       = aws_iam_role.eksNodesRole.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  role       = aws_iam_role.eksNodesRole.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# OIDC policy and role
data "aws_iam_policy_document" "cluster_assume_role_policy" {
  count = length(var.sa)
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks_groudplex_01.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:${element(var.sa, count.index)}"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks_groudplex_01.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "AmazonEKS_EBS_CSI_DriverRole" {
  assume_role_policy = data.aws_iam_policy_document.cluster_assume_role_policy.0.json
  name               = "AmazonEKS_EBS_CSI_Driver"
}

resource "aws_iam_role_policy_attachment" "AmazonEBSCSIDriverPolicy" {
  role       = aws_iam_role.AmazonEKS_EBS_CSI_DriverRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

resource "aws_iam_policy" "cluster_autoscaler" {
  name = "Cluster-Autoscaler"
  policy = jsonencode({
    Statement = [{
      Action = [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeAutoScalingInstances",
        "autoscaling:DescribeLaunchConfigurations",
        "autoscaling:DescribeTags",
        "autoscaling:SetDesiredCapacity",
        "autoscaling:TerminateInstanceInAutoScalingGroup",
        "ec2:DescribeLaunchTemplateVersions"
      ]
      Effect   = "Allow"
      Resource = "*"
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role" "AmazonEKSClusterAutoscalerRole" {
  assume_role_policy = data.aws_iam_policy_document.cluster_assume_role_policy.1.json
  name               = "AmazonEKSClusterAutoscaler"
}

resource "aws_iam_role_policy_attachment" "eks_ca_iam_policy_attach" {
  role       = aws_iam_role.AmazonEKSClusterAutoscalerRole.name
  policy_arn = aws_iam_policy.cluster_autoscaler.arn
}