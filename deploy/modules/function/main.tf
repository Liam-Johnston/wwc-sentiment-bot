resource "google_cloudfunctions_function" "function" {
  name    = var.function_name
  runtime = "nodejs16"

  available_memory_mb = 128
  trigger_http        = true
  entry_point         = var.function_entry_point

  source_archive_bucket = google_storage_bucket.archive_bucket.name
  source_archive_object = google_storage_bucket_object.archive.name

  secret_environment_variables {
    key     = "SLACK_SIGNING_SECRET"
    secret  = "slack-signing-secret"
    version = "latest"
  }

  service_account_email = google_service_account.service_account.email

  depends_on = [
    google_project_iam_member.custom_role
  ]
}

resource "google_cloudfunctions_function_iam_member" "invoker" {
  cloud_function = google_cloudfunctions_function.function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}
