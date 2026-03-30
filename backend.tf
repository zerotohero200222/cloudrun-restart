terraform {
  backend "gcs" {
    bucket  = "eighth-physics-489004-b2-tf-state"
    prefix  = "cloudrun-restart"
  }
}
