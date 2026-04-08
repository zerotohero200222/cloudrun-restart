output "restarted_service" {
  description = "Service that was redeployed"
  value       = google_cloud_run_service.service.name
}

output "new_revision" {
  description = "New revision created by this restart"
  value       = google_cloud_run_service.service.status[0].latest_ready_revision_name
}

output "service_url" {
  description = "Live URL of the restarted service"
  value       = google_cloud_run_service.service.status[0].url
}
