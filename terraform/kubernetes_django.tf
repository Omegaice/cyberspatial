output "django_ip" {
  value = "${kubernetes_service.django.load_balancer_ingress.0.ip}"
}

resource "kubernetes_service" "django" {
  metadata {
    name = "django"
  }
  spec {
    selector {
      app = "${kubernetes_replication_controller.django.metadata.0.labels.app}"
    }
    port {
      port = 80
      target_port = 8000
    }
    type = "LoadBalancer"
  }
}

resource "kubernetes_replication_controller" "django" {
  metadata {
    name = "django"
    labels {
      app = "django"
    }
  }
  spec {
    selector {
      app = "django"
    }
    template {
      container {
        name  = "django"
        image = "gcr.io/njcoast-174716/django"
        command = ["/start.sh"]
        env {
          name = "DJANGO_SETTINGS_MODULE"
          value = "njcoast.settings"
        }
        env {
          name = "DATABASE_URL"
          value = "postgres://njcoast:mysecretpassword@postgres:5432/postgres"
        }
        env {
          name = "ALLOWED_HOSTS"
          value = "['django',]"
        }
        env {
          name = "C_FORCE_ROOT"
          value = "1"
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
          name = "SITEURL"
          value = "http://njcoast.james-sweet.com/"
        }
        env {
          name = "BROKER_URL"
          value = "amqp://guest:guest@rabbitmq:5672/"
        }
        port {
          container_port = 8000
          name = "django"
        }
      }
    }
  }
  provisioner "local-exec" {
    command = "/bin/sh terraform/migrate_data.sh"
  }
  depends_on = [
    "kubernetes_replication_controller.postgres",
    "kubernetes_replication_controller.rabbitmq",
    "kubernetes_replication_controller.elasticsearch",
  ]
}