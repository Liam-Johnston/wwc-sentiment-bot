resource "google_storage_bucket_object" "entry_point_archive" {
  name   = "${filebase64sha256(local.entry_point_build_file)}.zip"
  bucket = google_storage_bucket.archive_bucket.name
  source = local.entry_point_build_file
}

resource "google_cloudfunctions_function" "ep_function" {
  name    = "slack-bot-entry-point"
  runtime = "nodejs16"

  available_memory_mb = 128
  trigger_http        = true
  entry_point         = "entryPoint"

  source_archive_bucket = google_storage_bucket.archive_bucket.name
  source_archive_object = google_storage_bucket_object.entry_point_archive.name

  secret_environment_variables {
    key     = "SLACK_SIGNING_SECRET"
    secret  = google_secret_manager_secret.slack_signing_secret.secret_id
    version = "latest"
  }

  environment_variables = {
    SLACK_EVENT_TOPIC = google_pubsub_topic.slack_event_topic.id
  }

  service_account_email = google_service_account.ep_service_account.email

  depends_on = [
    google_project_iam_member.ep_custom_role
  ]
}
