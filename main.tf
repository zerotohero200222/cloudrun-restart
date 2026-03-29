# Enable required APIs
resource "google_project_service" "apis" {
  for_each = toset([
    "run.googleapis.com",
    "cloudbuild.googleapis.com",
    "artifactregistry.googleapis.com"
  ])
  service = each.key
}

# Service account for Cloud Build trigger
resource "google_service_account" "cb_sa" {
  account_id   = "cloudrun-restart-sa"
  display_name = "Cloud Run Restart SA"
}

# Permissions
resource "google_project_iam_member" "run_admin" {
  role   = "roles/run.admin"
  member = "serviceAccount:${google_service_account.cb_sa.email}"
}

resource "google_project_iam_member" "sa_user" {
  role   = "roles/iam.serviceAccountUser"
  member = "serviceAccount:${google_service_account.cb_sa.email}"
}
