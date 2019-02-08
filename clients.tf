locals {
  clients_cn = [
    "apiserver-to-etcd",
    "service-accounts",
    "admin",
    "system:kube-controller-manager",
    "system:kube-scheduler",
    "system:kube-proxy",
  ]

  clients_ou = [
    "etcd",
    "k8s",
    "k8s",
    "k8s",
    "k8s",
    "k8s",
  ]
  clients_o = [
    "ZeroAE LLC",
    "ZeroAE LLC",
    "system:masters",
    "system:kube-controller-manager",
    "system:kube-scheduler",
    "system:node-proxier",
  ]
}
//
// Create client cert
resource "tls_private_key" "client" {
  count = "${length(local.clients_cn)}"

  algorithm = "${local.tls_algorithm}"
  rsa_bits  = "${local.tls_rsa_bits}"
}
resource "local_file" "client-key" {
  count = "${tls_private_key.client.count}"

  content  = "${tls_private_key.client.*.private_key_pem[count.index]}"
  filename = "${local.tls_folder}/${local.clients_cn[count.index]}-key.pem" 
}

resource "tls_cert_request" "client" {
  count = "${tls_private_key.client.count}"

  key_algorithm = "${tls_private_key.client.*.algorithm[count.index]}"
  private_key_pem = "${tls_private_key.client.*.private_key_pem[count.index]}"
  
  subject {
    common_name = "${local.clients_cn[count.index]}"
    organizational_unit = "${local.clients_ou[count.index]}"
    organization = "${local.clients_o[count.index]}"
  }
}
resource "local_file" "client-csr" {
  count = "${tls_cert_request.client.count}"

  content  = "${tls_cert_request.client.*.cert_request_pem[count.index]}"
  filename = "${local.tls_folder}/${local.clients_cn[count.index]}-csr.pem" 
}

resource "tls_locally_signed_cert" "client" {
  count = "${tls_cert_request.client.count}"

  cert_request_pem = "${tls_cert_request.client.*.cert_request_pem[count.index]}"
 
  ca_key_algorithm   = "${tls_private_key.ca.algorithm}"
  ca_private_key_pem = "${tls_private_key.ca.private_key_pem}"
  ca_cert_pem        = "${tls_self_signed_cert.ca.cert_pem}"

  validity_period_hours = 12

  allowed_uses = "${local.k8s_allowed_uses}"
}
resource "local_file" "client" {
  count = "${tls_locally_signed_cert.client.count}"

  content  = "${tls_locally_signed_cert.client.*.cert_pem[count.index]}"
  filename = "${local.tls_folder}/${local.clients_cn[count.index]}.pem" 
}
