provider "google" {
  project = "spacelift-development"
  region  = "us-central1"
}

resource "random_id" "suffix" {
  byte_length = 3
}

locals {
  name = "spacelift-nat-${random_id.suffix.hex}"
}

resource "google_compute_network" "this" {
  name                    = local.name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "this" {
  name          = local.name
  region        = "us-central1"
  network       = google_compute_network.this.self_link
  ip_cidr_range = "10.10.0.0/24"
}

module "spacelift-workers" {
  source = "./../../"

  configuration = <<EOF
export SPACELIFT_TOKEN=${var.spacelift_token}
export SPACELIFT_POOL_PRIVATE_KEY=${var.spacelift_pool_private_key}
  EOF

  worker_comms_url = "https://app.spacelift.io"

  network                     = google_compute_network.this.self_link
  subnetwork                  = google_compute_subnetwork.this.self_link
  region                      = "us-central1"
  zone                        = "us-central1-a"
  size                        = 2
  email                       = "spacelift-test-worker@spacelift-development.iam.gserviceaccount.com"
  instance_group_manager_name = local.name

  providers = {
    google = google
  }

  depends_on = [
    google_compute_router_nat.nat
  ]
}

resource "google_compute_router" "router" {
  name    = local.name
  region  = google_compute_subnetwork.this.region
  network = google_compute_network.this.self_link

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat" {
  name                               = local.name
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
