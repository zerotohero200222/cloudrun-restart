# ── Read the live service — never hardcode image or config ────────
data "google_cloud_run_service" "existing" {
  name     = var.target_service
  location = var.region
}

# ── Force a new revision by stamping RESTART_TIMESTAMP ───────────
resource "google_cloud_run_service" "service" {
  name     = var.target_service
  location = var.region

  template {
    spec {
      containers {
        # Always use the currently deployed image
        image = data.google_cloud_run_service.existing.template[0].spec[0].containers[0].image

        # Preserve every existing env var except RESTART_TIMESTAMP
        dynamic "env" {
          for_each = [
            for e in data.google_cloud_run_service.existing.template[0].spec[0].containers[0].env :
            e if e.name != "RESTART_TIMESTAMP"
          ]
          content {
            name  = env.value.name
            value = env.value.value
          }
        }

        # Unique on every apply → forces a new Cloud Run revision
        env {
          name  = "RESTART_TIMESTAMP"
          value = plantimestamp()
        }
      }

      service_account_name = data.google_cloud_run_service.existing.template[0].spec[0].service_account_name
    }

    metadata {
      annotations = data.google_cloud_run_service.existing.template[0].metadata[0].annotations
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  lifecycle {
    ignore_changes = [
      template[0].metadata[0].annotations["run.googleapis.com/client-name"],
      template[0].metadata[0].annotations["run.googleapis.com/client-version"],
    ]
  }
}
