resource "null_resource" "kubernetes_ingress_resource" {
  provisioner "local-exec" {
    command = "kubectl apply -f terraform/kubernetes_ingress.yaml"
  }
}