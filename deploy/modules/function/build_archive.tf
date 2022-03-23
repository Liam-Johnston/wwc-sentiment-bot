resource "google_storage_bucket" "archive_bucket" {
  name     = "${var.project_id}-${var.function_name}-archive-bucket"
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

resource "google_storage_bucket_object" "archive" {
  name   = "${filebase64sha256(var.build_file)}.zip"
  bucket = google_storage_bucket.archive_bucket.name
  source = var.build_file
}
