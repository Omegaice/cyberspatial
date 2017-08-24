resource "kubernetes_service" "rabbitmq" {
  metadata {
    name = "rabbitmq"
  }
  spec {
    selector {
      app = "${kubernetes_replication_controller.rabbitmq.metadata.0.labels.app}"
    }
    port {
      port = 5672
      target_port = 5672
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_replication_controller" "rabbitmq" {
  metadata {
    name = "rabbitmq"
    labels {
      app = "rabbitmq"
    }
  }
  spec {
    selector {
      app = "rabbitmq"
    }
    template {
      container {
        image = "rabbitmq:3.6.10-alpine"
        name  = "rabbitmq"
        port {
          container_port = 5432
          name = "rabbitmq"
        }
      }
    }
  }
}