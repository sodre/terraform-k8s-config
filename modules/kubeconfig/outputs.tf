output "kubeconfig" {
  value = "${data.template_file.this.*.rendered}"
}
