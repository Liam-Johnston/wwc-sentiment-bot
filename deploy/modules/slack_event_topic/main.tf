resource "google_pubsub_topic" "slack_event_topic" {
  name = "slack-event-${var.slack_event_type}"
}
