provider "google" {
  project     = "njcoast-174716"
  region      = "us-central1"
}

resource "google_container_cluster" "primary" {
  name               = "njcoast"
  zone               = "us-central1-b"
  initial_node_count = 2

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}

resource "google_compute_disk" "postgres-disk" {
  name  = "postgres-disk"
  type  = "pd-ssd"
  zone  = "us-central1-b"
  size  = 200
}

resource "google_compute_disk" "geoserver-disk" {
  name  = "geoserver-disk"
  type  = "pd-ssd"
  zone  = "us-central1-b"
  size  = 200
}