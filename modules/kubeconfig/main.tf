data "template_file" "this" {
  count = "${length(var.user_name)}" 

  template = "${file("${path.module}/templates/kubeconfig.yaml")}"
  vars {
    cluster_name   = "${var.cluster_name}"
    cluster_ca_b64 = "${base64encode(var.cluster_ca_cert_pem)}"
    cluster_server = "${var.cluster_apiserver}"

    user_name                = "${var.user_name[count.index]}"
    user_cert_pem_b64        = "${base64encode(var.user_cert_pem[count.index])}"
    user_private_key_pem_b64 = "${base64encode(var.user_private_key_pem[count.index])}"
  }
}
