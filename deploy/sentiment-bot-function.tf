resource "google_secret_manager_secret" "slack_oauth_token" {
  secret_id = "slack-oauth-token"

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "slack_oauth_token" {
  secret      = google_secret_manager_secret.slack_oauth_token.id
  secret_data = var.slack_oauth_token
}

resource "google_storage_bucket_object" "sentiment_bot_archive" {
  name   = "${filebase64sha256(local.sentiment_bot_build_file)}.zip"
  bucket = google_storage_bucket.archive_bucket.name
  source = local.sentiment_bot_build_file
}

resource "google_project_iam_custom_role" "sb_function_role" {
  role_id = "sentimentBot"
  title   = "Sentiment Slack Bot Role"
  permissions = [
    "secretmanager.versions.access"
  ]
}

resource "google_service_account" "sb_service_account" {
  account_id   = "sentiment-bot-sa"
  display_name = "sentiment bot sa"
  description  = "Service Account for the Sentiment Bot cloud function"
}

resource "google_project_iam_member" "sb_custom_role" {
  project = var.gcp_project_id
  role    = google_project_iam_custom_role.sb_function_role.id
  member  = "serviceAccount:${google_service_account.sb_service_account.email}"
}

resource "google_cloudfunctions_function" "sb_function" {
  name    = "sentiment-bot"
  runtime = "nodejs16"

  available_memory_mb = 128
  trigger_http        = true
  entry_point         = "entryPoint"

  source_archive_bucket = google_storage_bucket.archive_bucket.name
  source_archive_object = google_storage_bucket_object.sentiment_bot_archive.name

  service_account_email = google_service_account.sb_service_account.email

  secret_environment_variables {
    key     = "SLACK_OAUTH_TOKEN"
    secret  = google_secret_manager_secret.slack_oauth_token.secret_id
    version = "latest"
  }

  depends_on = [
    google_project_iam_member.sb_custom_role
  ]
}

resource "google_cloudfunctions_function_iam_member" "sb_invoker" {
  cloud_function = google_cloudfunctions_function.ep_function.name

  role   = "roles/cloudfunctions.invoker"
  member = "serviceAccount:${google_service_account.invoker_service_account.email}"
}
