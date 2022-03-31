resource "google_monitoring_notification_channel" "alert_group" {
  display_name = "Sentiment Bot Notification Channel"
  type         = "email"
  labels = {
    email_address = var.alert_email
  }
}

resource "google_monitoring_alert_policy" "cpu_high" {
  display_name = "High number of function executions"
  combiner     = "OR"
  documentation {
    content   = "Function execution exceeding ${local.execution_threshold}"
    mime_type = "text/markdown"
  }
  conditions {
    display_name = "Cloud Function - Executions"
    condition_threshold {
      filter     = "resource.type = \"cloud_function\" AND resource.labels.function_name = \"${var.function_name}\" AND metric.type = \"cloudfunctions.googleapis.com/function/execution_count\" AND metric.labels.status = \"ok\""
      duration   = "0s"
      comparison = "COMPARISON_GT"
      aggregations {
        alignment_period   = "86400s"
        per_series_aligner = "ALIGN_COUNT"
      }
      threshold_value = 3000
      trigger {
        count = 1
      }
    }
  }
  notification_channels = [google_monitoring_notification_channel.alert_group.name]
}
