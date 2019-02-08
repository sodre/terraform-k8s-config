resource "tls_private_key" "ca" {
  algorithm = "${local.tls_algorithm}"
  rsa_bits  = "${local.tls_rsa_bits}"
}
resource "local_file" "ca-key" {
  content  = "${tls_private_key.ca.private_key_pem}"
  filename = "${local.tls_folder}/ca-key.pem" 
}
resource "tls_self_signed_cert" "ca" {
  key_algorithm   = "${tls_private_key.ca.algorithm}"
  private_key_pem = "${tls_private_key.ca.private_key_pem}"

  validity_period_hours = 12

  is_ca_certificate = true
  allowed_uses = [
    "cert_signing"
  ]

  subject {
    common_name = "kubernetes-ca"
    organization = "ZeroAE LLC"
  }
}
resource "local_file" "ca" {
  content  = "${tls_self_signed_cert.ca.cert_pem}"
  filename = "${local.tls_folder}/ca.pem" 
}
