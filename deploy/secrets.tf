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
