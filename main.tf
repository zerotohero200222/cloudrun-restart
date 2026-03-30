# Enable APIs
resource "google_project_service" "apis" {
  for_each = toset([
    "run.googleapis.com",
    "cloudbuild.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ])
  project = var.project_id
  service = each.key
}

# Restart Cloud Run using gcloud
resource "null_resource" "restart_cloud_run" {

  provisioner "local-exec" {
    command = <<EOT
      gcloud run services update ${var.service_name} \
        --region=${var.region} \
        --update-env-vars=RESTART_TRIGGER=$(date +%s) \
        --project=${var.project_id}
    EOT
  }

  triggers = {
    always_run = timestamp()
  }
}
