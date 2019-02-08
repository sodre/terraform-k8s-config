locals {
  tls_algorithm = "RSA"
  tls_rsa_bits = 2048

  tls_folder = "../tls"


   k8s_allowed_uses = [
     "signing",
     "key_encipherment",
     "server_auth",
     "client_auth"
   ]
}


locals {
  kubeconfig_users = [ 
    "${local.clients_cn[2]}"
  ]
  kubeconfig_cert_pem = [
    "${tls_locally_signed_cert.client.2.cert_pem}"
  ]
  kubeconfig_private_key_pem = [
    "${tls_private_key.client.2.private_key_pem}"
  ]
}
module "kubeconfig" {
  source = "modules/kubeconfig"

  cluster_ca_cert_pem = "${tls_self_signed_cert.ca.cert_pem}"

  user_name = "${local.kubeconfig_users}"
  user_cert_pem = "${local.kubeconfig_cert_pem}"
  user_private_key_pem = "${local.kubeconfig_private_key_pem}"
}
