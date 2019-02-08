variable "cluster_name" {
  default = "k8s"
}


variable "cluster_ca_cert_pem" {
  description = "The Cluster's Certificate of Authority PEM"
}
variable "cluster_apiserver" {
  default = "https://127.0.0.1:6443"
  description = "The address to the cluster's endpoint"
}


variable "user_name" {
  type = "list"
  description = "The k8s cluster username(s)"
}
variable "user_cert_pem" {
  type = "list"
  description = "The user's certificate pems."
}
variable "user_private_key_pem" {
  type = "list"
  description = "The k8s user private key."
}
