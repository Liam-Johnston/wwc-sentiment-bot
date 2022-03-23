module "slack_bot_function" {
  source = "./modules/function"

  function_name        = "slack-bot-entry-point"
  project_id           = var.project_id
  build_file           = "/dist/function.zip"
  function_entry_point = "entryPoint"
}

module "slack_event_topic" {
  source   = "./modules/slack_event_topic"
  for_each = toset(local.supported_slack_event_types)

  slack_event_type = each.value
}
