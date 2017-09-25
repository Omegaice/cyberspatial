resource "null_resource" "kubernetes_ingress_resource" {
  provisioner "local-exec" {
    command = "kubectl apply -f lego/00-namespace.yaml"
  }

  provisioner "local-exec" {
    command = "kubectl apply -f lego/configmap.yaml"
  }

  provisioner "local-exec" {
    command = "kubectl apply -f lego/deployment.yaml"
  }

  provisioner "local-exec" {
    command = "kubectl apply -f terraform/kubernetes_ingress.yaml"
  }
}