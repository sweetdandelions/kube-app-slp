# OIDC policy and role
data "aws_iam_policy_document" "cluster_assume_role_policy" {
  #count = length(var.sa)
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks_groudplex_01.url, "https://", "")}:sub"
      #values   = ["system:serviceaccount:kube-system:${element(var.sa, count.index)}"]
      values   = ["system:serviceaccount:kube-system:cluster-autoscaler"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks_groudplex_01.arn]
      type        = "Federated"
    }
  }
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
    },
    {
      Action: [
        "autoscaling:SetDesiredCapacity",
        "autoscaling:TerminateInstanceInAutoScalingGroup",
        "ec2:DescribeImages",
        "ec2:GetInstanceTypesFromInstanceRequirements",
        "eks:DescribeNodegroup"
      ]
      Effect: "Allow",
      Resource: ["*"]
  }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role" "AmazonEKSClusterAutoscalerRole" {
  assume_role_policy = data.aws_iam_policy_document.cluster_assume_role_policy.json
  name               = "AmazonEKSClusterAutoscaler"
}

resource "aws_iam_role_policy_attachment" "eks_ca_iam_policy_attach" {
  role       = aws_iam_role.AmazonEKSClusterAutoscalerRole.name
  policy_arn = aws_iam_policy.cluster_autoscaler.arn
}