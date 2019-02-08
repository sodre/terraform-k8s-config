locals {
  tls_algorithm = "RSA"
  tls_rsa_bits = 2048

  tls_folder = "../tls"
  kubernetes_folder = "../etc/kubernetes"


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
    "${tls_locally_signed_cert.client.*.cert_pem[2]}"
  ]
  kubeconfig_private_key_pem = [
    "${tls_private_key.client.*.private_key_pem[2]}"
  ]
}
module "kubeconfig" {
  source = "modules/kubeconfig"

  cluster_ca_cert_pem = "${tls_self_signed_cert.ca.cert_pem}"

  user_name = "${local.kubeconfig_users}"
  user_cert_pem = "${local.kubeconfig_cert_pem}"
  user_private_key_pem = "${local.kubeconfig_private_key_pem}"
}
resource "local_file" "kubeconfig" {
  count = "${length(local.kubeconfig_users)}"

  content  = "${module.kubeconfig.kubeconfig[count.index]}"
  filename = "${local.kubernetes_folder}/${local.kubeconfig_users[count.index]}.kubeconfig" 
}
