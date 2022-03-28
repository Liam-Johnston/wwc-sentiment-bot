resource "google_storage_bucket" "archive_bucket" {
  name     = "${var.gcp_project_id}-function-archive-bucket"
  location = "US"

  lifecycle_rule {
    condition {
      age = 1
    }
    action {
      type = "Delete"
    }
  }
}
