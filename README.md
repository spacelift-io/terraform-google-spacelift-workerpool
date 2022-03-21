# terraform-google-spacelift-workerpool

Terraform module deploying a Spacelift worker pool on Google Cloud Platform using an Instance Group Manager.

## Usage

```terraform
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.14.0"
    }
  }
}

module "my_workerpool" {
  source = "github.com/spacelift-io/terraform-google-spacelift-workerpool?ref=204ee66d6fbcfe09c3b7a048f5908ff376a0eff1"

  configuration = <<-EOT
    export SPACELIFT_TOKEN="${var.worker_pool_config}"
    export SPACELIFT_POOL_PRIVATE_KEY="${var.worker_pool_private_key}"
  EOT

  image   = "projects/spacelift-workers/global/images/spacelift-worker-us-1634112379-tmoys2fp"
  network = "default"
  region  = "us-central1"
  zone    = "us-central1-a"
  size    = 2
  email   = "abc@xyz.iam.gserviceaccount.com"
  
  providers = {
    google = google
  }
}
```

## Default Image

The default Image used by this module comes from the [spacelift-worker-image](https://github.com/spacelift-io/spacelift-worker-image)
repository. You can find the full list of AMIs on the [releases](https://github.com/spacelift-io/spacelift-worker-image/releases)
page.
