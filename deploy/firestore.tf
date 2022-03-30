resource "google_app_engine_application" "empty-app" {
  project     = var.gcp_project_id
  location_id = var.gcp_region

  database_type = "CLOUD_FIRESTORE"
}
