terraform {
  # No GCS backend — local state only.
  # Each Cloud Build run starts fresh with no state memory,
  # so there is no stale lock, no destroy+create, no import needed.
  # Terraform simply calls the GCP API to update the existing service.

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

