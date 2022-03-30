resource "google_pubsub_topic" "slack_event_topic" {
  name = "slack-event"
}

resource "google_pubsub_subscription" "event_sub" {
  name  = "sentiment-bot-slack-event-sub"
  topic = google_pubsub_topic.slack_event_topic.id

  ack_deadline_seconds = 10
  filter               = "NOT attributes:subtype AND NOT attributes:thread_ts"

  push_config {
    push_endpoint = google_cloudfunctions_function.sb_function.https_trigger_url
    oidc_token {
      service_account_email = google_service_account.invoker_service_account.email
    }
  }
}
