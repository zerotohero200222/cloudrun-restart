variable "project_id" {
  type    = string
  default = "eighth-physics-489004-b2"
}

variable "region" {
  type    = string
  default = "us-central1"
}

# The one stuck service you want to restart right now.
# Change this value in terraform.tfvars, then trigger Cloud Build.
variable "target_service" {
  type        = string
  description = "Name of the Cloud Run service to restart"
}
