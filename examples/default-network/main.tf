provider "google" {
  project     = "spacelift-development"
  region      = "us-central1"
}

module "spacelift-workers" {
  source = "./../../"

  configuration = <<EOF
export SPACELIFT_TOKEN=${var.spacelift_token}
export SPACELIFT_POOL_PRIVATE_KEY=${var.spacelift_pool_private_key}
  EOF

  network = "default"
  region  = "us-central1"
  zone    = "us-central1-a"
  size    = 2
  email   = "spacelift-test-worker@spacelift-development.iam.gserviceaccount.com"

  providers = {
    google = google
  }

  depends_on = [
    google_compute_router_nat.nat
  ]
}

resource "google_compute_router" "router" {
  name    = "my-router"
  region  = "us-central1"
  network = "default"

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat" {
  name                               = "my-router-nat"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
