resource "google_secret_manager_secret" "slack_signing_secret" {
  secret_id = "slack-signing-secret"

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "slack_signing_secret" {
  secret      = google_secret_manager_secret.slack_signing_secret.id
  secret_data = var.slack_signing_secret
}

resource "google_storage_bucket_object" "entry_point_archive" {
  name   = "${filebase64sha256(local.entry_point_build_file)}.zip"
  bucket = google_storage_bucket.archive_bucket.name
  source = local.entry_point_build_file
}

resource "google_project_iam_custom_role" "ep_function_role" {
  role_id = "entryPointSlackBot"
  title   = "Entry Point Slack Bot Role"
  permissions = [
    "pubsub.topics.publish",
    "secretmanager.versions.access"
  ]
}

resource "google_service_account" "ep_service_account" {
  account_id   = "slack-bot-ep-sa"
  display_name = "slack bot entry point sa"
  description  = "Service Account for the Slack Bot entry point cloud function"
}

resource "google_project_iam_member" "ep_custom_role" {
  project = var.gcp_project_id
  role    = google_project_iam_custom_role.ep_function_role.id
  member  = "serviceAccount:${google_service_account.ep_service_account.email}"
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

resource "google_cloudfunctions_function_iam_member" "ep_invoker" {
  cloud_function = google_cloudfunctions_function.ep_function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}
