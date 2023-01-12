provider "google" {
  project = "spacelift-development"
  region  = "us-central1"
}

module "spacelift-workers" {
  source = "./../../"

  configuration = <<EOF
export SPACELIFT_TOKEN=${var.spacelift_token}
export SPACELIFT_POOL_PRIVATE_KEY=${var.spacelift_pool_private_key}
  EOF

  network                     = "default"
  region                      = "us-central1"
  zone                        = "us-central1-a"
  size                        = 2
  email                       = "spacelift-test-worker@spacelift-development.iam.gserviceaccount.com"
  instance_group_manager_name = "spacelift-workers-custom-oauth"

  service_account_scopes = [
    "https://www.googleapis.com/auth/compute",
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/ndev.clouddns.readwrite",
    "https://www.googleapis.com/auth/devstorage.full_control",
    "https://www.googleapis.com/auth/userinfo.email",
  ]

  providers = {
    google = google
  }
}
