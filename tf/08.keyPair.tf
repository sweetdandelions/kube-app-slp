resource "tls_private_key" "priv_key" {
  algorithm = "RSA"
}

resource "aws_key_pair" "key" {
  key_name   = "eks_key"
  public_key = tls_private_key.priv_key.public_key_openssh

  depends_on = [
    tls_private_key.priv_key
  ]
}

resource "local_file" "key_file" {
  content  = tls_private_key.priv_key.private_key_pem
  filename = "eks_key.pem"

  depends_on = [
    tls_private_key.priv_key
  ]
}