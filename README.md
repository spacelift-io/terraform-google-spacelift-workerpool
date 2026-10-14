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
  source = "github.com/spacelift-io/terraform-google-spacelift-workerpool?ref=v3.0.0"

  configuration = <<-EOT
    export SPACELIFT_TOKEN="${var.worker_pool_config}"
    export SPACELIFT_POOL_PRIVATE_KEY="${var.worker_pool_private_key}"
  EOT

  worker_comms_url = "https://app.spacelift.io"

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

## Worker Communication

Starting with v3.0.0, workers use HTTP long-polling by default. The module exports `SPACELIFT_WORKER_COMMS_PROTOCOL=poll` and `SPACELIFT_WORKER_COMMS_URL` to the launcher. This replaces the deprecated MQTT transport and means workers only need outbound HTTPS access to the Spacelift server for worker communication.

When the protocol is `poll`, `worker_comms_url` is **required** and the plan fails if it is not set. Use `https://app.spacelift.io` for EU SaaS, `https://app.us.spacelift.io` for US SaaS, or the base URL provided for your self-hosted or FedRAMP Spacelift environment.

This default change is **breaking** because existing worker pools switch transports when the instance group manager replaces their instances with the new template. Ensure outbound HTTPS access to the communication URL before upgrading. To temporarily remain on MQTT during migration, set `worker_comms_protocol = "mqtt"`. See the [v2.x to v3.0 upgrade guide](./docs/upgrade/v2.x-to-v3.0.md) for details.

The module exports these values before `configuration` runs, so values in `configuration` can still override them, but using `worker_comms_protocol` and `worker_comms_url` is recommended.

## Service Account Scopes

With `hashicorp/google` provider 8.2.0 or later, set at least one scope in `service_account_scopes`. When the list is empty, which is the default, the provider crashes while creating the instance template. Google recommends `https://www.googleapis.com/auth/cloud-platform` combined with IAM roles on the service account.

## Default Image

The default Image used by this module comes from the [spacelift-worker-image](https://github.com/spacelift-io/spacelift-worker-image)
repository. You can find the full list of AMIs on the [releases](https://github.com/spacelift-io/spacelift-worker-image/releases)
page.

This module automatically uses the FedRAMP worker image for FedRAMP worker pools.
