//
// Create apiserver-to-etcd client cert
resource "tls_private_key" "apiserver-to-etcd" {
  algorithm = "${local.tls_algorithm}"
  rsa_bits  = "${local.tls_rsa_bits}"
}
resource "local_file" "apiserver-to-etcd-key" {
  content  = "${tls_private_key.apiserver-to-etcd.private_key_pem}"
  filename = "${local.tls_folder}/apiserver-to-etcd-key.pem" 
}
resource "tls_cert_request" "apiserver-to-etcd" {
  key_algorithm = "${tls_private_key.apiserver-to-etcd.algorithm}"
  private_key_pem = "${tls_private_key.apiserver-to-etcd.private_key_pem}"
  
  subject {
    common_name = "apiserver"
    organizational_unit = "etcd"
    organization = "ZeroAE LLC"
  }
}
resource "local_file" "apiserver-to-etcd-csr" {
  content  = "${tls_cert_request.apiserver-to-etcd.cert_request_pem}"
  filename = "${local.tls_folder}/apiserver-to-etcd-csr.pem" 
}
resource "tls_locally_signed_cert" "apiserver-to-etcd" {
  cert_request_pem = "${tls_cert_request.apiserver-to-etcd.cert_request_pem}"
 
  ca_key_algorithm   = "${tls_private_key.ca.algorithm}"
  ca_private_key_pem = "${tls_private_key.ca.private_key_pem}"
  ca_cert_pem        = "${tls_self_signed_cert.ca.cert_pem}"

  validity_period_hours = 12

  allowed_uses = "${local.k8s_allowed_uses}"
}
resource "local_file" "apiserver-to-etcd" {
  content  = "${tls_locally_signed_cert.apiserver-to-etcd.cert_pem}"
  filename = "${local.tls_folder}/apiserver-to-etcd.pem"
}
