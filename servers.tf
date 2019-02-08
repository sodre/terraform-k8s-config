locals {
  server_cns = [
    "etcd",
    "apiserver"
  ]
}
//
// Create etcd server key/certs
resource "tls_private_key" "server" {
  count = "${length(local.server_cns)}"

  algorithm = "${local.tls_algorithm}"
  rsa_bits  = "${local.tls_rsa_bits}"
}
resource "local_file" "server-key" {
  count = "${tls_private_key.server.count}"

  content  = "${tls_private_key.server.*.private_key_pem[count.index]}"
  filename = "${local.tls_folder}/${local.server_cns[count.index]}-key.pem" 
}

resource "tls_cert_request" "server" {
  count = "${tls_private_key.server.count}"

  key_algorithm = "${tls_private_key.server.*.algorithm[count.index]}"
  private_key_pem = "${tls_private_key.server.*.private_key_pem[count.index]}"
  
  subject {
    common_name = "etcd"
    organizational_unit = "etcd"
    organization = "ZeroAE LLC"
  }

  dns_names = [
    "localhost",
    "linux-anvil"
  ]
  ip_addresses = [
    "127.0.0.1",
    "192.168.131.59"
  ]
}
resource "local_file" "server-csr" {
  count = "${tls_cert_request.server.count}"

  content  = "${tls_cert_request.server.*.cert_request_pem[count.index]}"
  filename = "${local.tls_folder}/${local.server_cns[count.index]}-csr.pem" 
}

resource "tls_locally_signed_cert" "server" {
  count = "${tls_cert_request.server.count}"

  cert_request_pem = "${tls_cert_request.server.*.cert_request_pem[count.index]}"
 
  ca_key_algorithm   = "${tls_private_key.ca.algorithm}"
  ca_private_key_pem = "${tls_private_key.ca.private_key_pem}"
  ca_cert_pem        = "${tls_self_signed_cert.ca.cert_pem}"

  validity_period_hours = 12

  allowed_uses = "${local.k8s_allowed_uses}"
}
resource "local_file" "server" {
  count = "${tls_locally_signed_cert.server.count}"

  content  = "${tls_locally_signed_cert.server.*.cert_pem[count.index]}"
  filename = "${local.tls_folder}/${local.server_cns[count.index]}.pem"
}
