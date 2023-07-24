# OIDC policy and role
data "aws_iam_policy_document" "ebs_assume_role_policy" {
  #count = length(var.sa)
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks_groudplex_01.url, "https://", "")}:sub"
      #values   = ["system:serviceaccount:kube-system:${element(var.sa, count.index)}"]
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks_groudplex_01.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "AmazonEKS_EBS_CSI_DriverRole" {
  assume_role_policy = data.aws_iam_policy_document.ebs_assume_role_policy.json
  name               = "AmazonEKS_EBS_CSI_Driver"
}

resource "aws_iam_role_policy_attachment" "AmazonEBSCSIDriverPolicy" {
  role       = aws_iam_role.AmazonEKS_EBS_CSI_DriverRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}