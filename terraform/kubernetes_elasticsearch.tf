resource "kubernetes_service" "elasticsearch" {
  metadata {
    name = "elasticsearch"
  }
  spec {
    selector {
      app = "${kubernetes_replication_controller.elasticsearch.metadata.0.labels.app}"
    }
    port {
      port = 9200
      target_port = 9200
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_replication_controller" "elasticsearch" {
  metadata {
    name = "elasticsearch"
    labels {
      app = "elasticsearch"
    }
  }
  spec {
    selector {
      app = "elasticsearch"
    }
    template {
      container {
        image = "elasticsearch"
        name  = "elasticsearch"
        port {
          container_port = 9200
          name = "elasticsearch"
        }
      }
    }
  }
}