data "tls_certificate" "cluster" {
  url = aws_eks_cluster.eks_groudplex_01.identity.0.oidc.0.issuer
}

resource "aws_iam_openid_connect_provider" "eks_groudplex_01" {
    client_id_list = ["sts.amazonaws.com"]
    thumbprint_list = [data.tls_certificate.cluster.certificates.0.sha1_fingerprint]
    url = aws_eks_cluster.eks_groudplex_01.identity.0.oidc.0.issuer
}