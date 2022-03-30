### Entry point IAM resources
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

resource "google_cloudfunctions_function_iam_member" "ep_invoker" {
  cloud_function = google_cloudfunctions_function.ep_function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}

### Sentiment Bot IAM resources
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

resource "google_project_iam_member" "firestore_access_role" {
  project = var.gcp_project_id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${google_service_account.sb_service_account.email}"
}

resource "google_cloudfunctions_function_iam_member" "sb_invoker" {
  cloud_function = google_cloudfunctions_function.ep_function.name

  role   = "roles/cloudfunctions.invoker"
  member = "serviceAccount:${google_service_account.invoker_service_account.email}"
}

### Pub/Sub IAM resources

resource "google_service_account" "invoker_service_account" {
  account_id   = "sentiment-bot-invoker"
  display_name = "Sentiment Bot pub sub invoker"
}

resource "google_project_iam_member" "custom_role" {
  project = var.gcp_project_id
  role    = "roles/cloudfunctions.invoker"
  member  = "serviceAccount:${google_service_account.invoker_service_account.email}"
}
