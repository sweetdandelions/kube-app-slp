
data "aws_iam_policy_document" "ssm_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks_groudplex_01.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:snaplogic:snaplogic-sa"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks_groudplex_01.arn]
      type        = "Federated"
    }
  }
}
resource "aws_iam_policy" "ssm" {
  name = "SnaplogicSecret"
  policy = jsonencode({
    Statement = [{
      Action = [
        "secretsmanager:DescribeSecret",
        "secretsmanager:GetSecretValue"
      ]
      Effect   = "Allow"
      Resource = "<secret arn>"
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role" "SnaplogicSecret" {
  assume_role_policy = data.aws_iam_policy_document.ssm_assume_role_policy.json
  name               = "SnaplogicSecret"
}

resource "aws_iam_role_policy_attachment" "slp_ss_iam_policy_attach" {
  role       = aws_iam_role.SnaplogicSecret.name
  policy_arn = aws_iam_policy.ssm.arn
}