# Enable required APIs (safe guard)
resource "google_project_service" "apis" {
  for_each = toset([
    "run.googleapis.com"
  ])

  project = var.project_id
  service = each.key
}

# Restart Cloud Run (NO IMAGE USED)
resource "null_resource" "restart_cloud_run" {

  provisioner "local-exec" {
    command = <<EOT
      echo "Restarting Cloud Run: ${var.service_name}"

      gcloud run services update ${var.service_name} \
        --region=${var.region} \
        --project=${var.project_id} \
        --update-env-vars=RESTART_TRIGGER=$(date +%s)

      echo "Restart completed"
    EOT
  }

  triggers = {
    always_run = timestamp()
  }
}
