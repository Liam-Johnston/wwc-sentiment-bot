output "entry_point_invoke_url" {
  value = google_cloudfunctions_function.ep_function.https_trigger_url
}
