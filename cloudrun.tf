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
        # Always use the currently deployed image — never hardcode
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

        # Unique value on every apply → forces Cloud Run to create a NEW revision
        env {
          name  = "RESTART_TIMESTAMP"
          value = plantimestamp()
        }
      }

      service_account_name = data.google_cloud_run_service.existing.template[0].spec[0].service_account_name
    }

    # Do NOT copy annotations from the live service — Cloud Run manages
    # these internally and setting them causes the stuck "creating" loop
    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale"     = lookup(data.google_cloud_run_service.existing.template[0].metadata[0].annotations, "autoscaling.knative.dev/maxScale", "10")
        "autoscaling.knative.dev/minScale"     = lookup(data.google_cloud_run_service.existing.template[0].metadata[0].annotations, "autoscaling.knative.dev/minScale", "0")
        "run.googleapis.com/startup-cpu-boost" = lookup(data.google_cloud_run_service.existing.template[0].metadata[0].annotations, "run.googleapis.com/startup-cpu-boost", "false")
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  lifecycle {
    # Let Cloud Run manage its own client metadata stamps
    ignore_changes = [
      template[0].metadata[0].annotations["run.googleapis.com/client-name"],
      template[0].metadata[0].annotations["run.googleapis.com/client-version"],
    ]
  }
}
