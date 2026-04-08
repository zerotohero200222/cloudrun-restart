terraform {
  backend "gcs" {
    bucket = "eighth-physics-489004-b2-tf-state"
    prefix = "cloudrun-restart"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

