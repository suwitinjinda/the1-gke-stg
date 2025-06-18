provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

resource "google_project" "gke_project" {
  name       = var.project        # Project display name
  project_id = var.project
  org_id     = var.org_id         # Add this variable in variables.tf
  billing_account = var.billing_account_id
}

# resource "google_project_service" "compute" {
#   project = "the1-gke-stg"
#   service = "compute.googleapis.com"
# }

# resource "google_project_service" "gke" {
#   project = "the1-gke-stg"
#   service = "container.googleapis.com"
# }