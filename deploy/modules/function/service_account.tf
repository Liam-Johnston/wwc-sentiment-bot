resource "google_project_iam_custom_role" "function_role" {
  role_id = "continoSlackBot"
  title   = "Contino Slack Bot Role"
  permissions = [
    "pubsub.topics.publish",
    "secretmanager.versions.access"
  ]
}

resource "google_service_account" "service_account" {
  account_id   = "contino-slack-bot-sa"
  display_name = "contino slack bot sa"
  description  = "Service Account for the Contino Slack Bot cloud function"
}

resource "google_project_iam_member" "custom_role" {
  project = var.project_id
  role    = google_project_iam_custom_role.function_role.id
  member  = "serviceAccount:${google_service_account.service_account.email}"
}
