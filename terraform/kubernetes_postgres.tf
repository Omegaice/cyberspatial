resource "kubernetes_service" "postgres" {
  metadata {
    name = "postgres"
  }
  spec {
    selector {
      app = "${kubernetes_replication_controller.postgres.metadata.0.labels.app}"
    }
    port {
      port = 5432
      target_port = 5432
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_replication_controller" "postgres" {
  metadata {
    name = "postgres"
    labels {
      app = "postgres"
    }
  }
  spec {
    selector {
      app = "postgres"
    }
    template {
      container {
        image = "mdillon/postgis:9.6-alpine"
        name  = "postgres"
        env {
          name = "POSTGRES_USER"
          value_from {
            secret_key_ref {
              name = "${kubernetes_secret.postgres.metadata.0.name}"
              key = "username"
            }
          }
        }
        env{
          name = "POSTGRES_PASSWORD"
          value_from {
            secret_key_ref {
              name = "${kubernetes_secret.postgres.metadata.0.name}"
              key = "password"
            }
          }
        }
        port {
          container_port = 5432
          name = "postgres"
        }
        volume_mount {
          name = "postgres-persistent-storage"
          mount_path = "/var/lib/postgresql/data"
          sub_path = "data/"
        }
      }
      volume {
        name = "postgres-persistent-storage"
        persistent_volume_claim {
          claim_name = "${kubernetes_persistent_volume_claim.postgres.metadata.0.name}"
        }
      }
    }
  }
}

resource "kubernetes_secret" "postgres" {
  metadata {
    name = "postgres-auth"
  }
  data {
    username = "postgres"
    password = "mysecretpassword"
  }
}

resource "kubernetes_persistent_volume_claim" "postgres" {
  metadata {
    name = "postgres"
  }
  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests {
        storage = "5Gi"
      }
    }
    volume_name = "${kubernetes_persistent_volume.postgres.metadata.0.name}"
  }
  depends_on = ["google_compute_disk.postgres-disk"]
}

resource "kubernetes_persistent_volume" "postgres" {
    metadata {
        name = "postgres"
    }
    spec {
        capacity {
            storage = "5Gi"
        }
        access_modes = ["ReadWriteMany"]
        persistent_volume_source {
            gce_persistent_disk {
                pd_name = "postgres-disk"
                fs_type = "ext4"
            }
        }
    }
}