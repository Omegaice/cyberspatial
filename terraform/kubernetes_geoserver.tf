output "geoserver_ip" {
  value = "${kubernetes_service.geoserver.load_balancer_ingress.0.ip}"
}

resource "kubernetes_service" "geoserver" {
  metadata {
    name = "geoserver"
  }
  spec {
    selector {
      app = "${kubernetes_replication_controller.geoserver.metadata.0.labels.app}"
    }
    port {
      port = 8080
      target_port = 8080
    }
    type = "NodePort"
  }
}

resource "kubernetes_replication_controller" "geoserver" {
  metadata {
    name = "geoserver"
    labels {
      app = "geoserver"
    }
  }
  spec {
    selector {
      app = "geoserver"
    }
    template {
      container {
        name  = "geoserver"
        image = "gcr.io/njcoast-174716/geoserver"
        env {
          name = "PUBLIC_PORT"
          value = "80"
        }
        env {
          name = "DJANGO_URL"
          value = "http://njcoast.james-sweet.com/"
        }
        env {
          name = "GEOSERVER_PUBLIC_LOCATION"
          value = "http://njcoast.james-sweet.com/geoserver/"
        }
        env {
          name = "GEOSERVER_LOCATION"
          value = "http://njcoast.james-sweet.com/geoserver/"
        }
        env {
          name = "GEOSERVER_DATA_DIR"
          value = "/geoserver_data/data"
        }
        env {
          name = "SITEURL"
          value = "http://njcoast.james-sweet.com/geoserver/"
        }
        port {
          container_port = 8080
          name = "geoserver"
        }
        volume_mount {
          name = "geoserver-persistent-storage"
          mount_path = "/geoserver_data/data"
        }
      }
      volume {
        name = "geoserver-persistent-storage"
        persistent_volume_claim {
          claim_name = "${kubernetes_persistent_volume_claim.geoserver.metadata.0.name}"
        }
      }
    }
  }
  depends_on = [
    "kubernetes_replication_controller.postgres",
  ]
}

resource "kubernetes_persistent_volume_claim" "geoserver" {
  metadata {
    name = "geoserver"
  }
  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests {
        storage = "5Gi"
      }
    }
    volume_name = "${kubernetes_persistent_volume.geoserver.metadata.0.name}"
  }
  depends_on = ["google_compute_disk.geoserver-disk"]
}

resource "kubernetes_persistent_volume" "geoserver" {
    metadata {
        name = "geoserver"
    }
    spec {
        capacity {
            storage = "5Gi"
        }
        access_modes = ["ReadWriteMany"]
        persistent_volume_source {
            gce_persistent_disk {
                pd_name = "geoserver-disk"
                fs_type = "ext4"
            }
        }
    }
}