provider "google" {
  project = "spacelift-development"
  region  = "us-central1"
}

module "spacelift-workers" {
  source = "./../../"

  configuration = <<EOF
export SPACELIFT_TOKEN="<token-here>"
export SPACELIFT_POOL_PRIVATE_KEY="<private-key-here>"
  EOF

  network                     = "default"
  region                      = "us-central1"
  zone                        = "us-central1-a"
  size                        = 1
  email                       = "spacelift-test-worker@spacelift-development.iam.gserviceaccount.com"
  instance_group_manager_name = "spacelift-workers-missing-url"

  # NEGATIVE TEST: worker_comms_protocol defaults to "poll", which requires
  # worker_comms_url. It is deliberately omitted here so the plan must fail
  # with the module's precondition error.

  providers = {
    google = google
  }
}
