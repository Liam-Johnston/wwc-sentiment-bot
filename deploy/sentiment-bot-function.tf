resource "google_storage_bucket_object" "sentiment_bot_archive" {
  name   = "${filebase64sha256(local.sentiment_bot_build_file)}.zip"
  bucket = google_storage_bucket.archive_bucket.name
  source = local.sentiment_bot_build_file
}

resource "google_cloudfunctions_function" "sb_function" {
  name    = "sentiment-bot"
  runtime = "nodejs16"

  available_memory_mb = 128
  trigger_http        = true
  entry_point         = "entryPoint"
  timeout             = local.sentiment_bot_timeout

  source_archive_bucket = google_storage_bucket.archive_bucket.name
  source_archive_object = google_storage_bucket_object.sentiment_bot_archive.name

  service_account_email = google_service_account.sb_service_account.email

  secret_environment_variables {
    key     = "SLACK_OAUTH_TOKEN"
    secret  = google_secret_manager_secret.slack_oauth_token.secret_id
    version = "latest"
  }

  environment_variables = {
    LEASE_FIRESTORE_COLLECTION = "sentiment-event-lease"
    LEASE_DURATION             = local.sentiment_bot_timeout
  }

  depends_on = [
    google_project_iam_member.sb_custom_role
  ]
}
