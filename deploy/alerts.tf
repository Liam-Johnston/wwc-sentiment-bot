module "execution_alert" {
  count = var.alert_email != "" ? 1 : 0

  source = "./modules/alerts"

  alert_email   = var.alert_email
  function_name = google_cloudfunctions_function.sb_function.name
}
