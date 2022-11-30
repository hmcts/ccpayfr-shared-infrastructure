

module "feepay-fail-alert" {
  source            = "git@github.com:hmcts/cnp-module-metric-alert"
  location          = azurerm_application_insights.appinsights.location
  app_insights_name = azurerm_application_insights.appinsights.name

  alert_name                 = "feepay-fail-alert"
  alert_desc                 = "Triggers when an feepay exception is received in a 5 minute poll."
  app_insights_query         = "requests | where toint(resultCode) >= 400 | sort by timestamp desc"
  frequency_in_minutes       = 15
  time_window_in_minutes     = 15
  severity_level             = "3"
  action_group_name          = module.feepay-fail-action-group-slack.action_group_name
  custom_email_subject       = "feepay Service Exception"
  trigger_threshold_operator = "GreaterThan"
  trigger_threshold          = 0
  resourcegroup_name         = azurerm_resource_group.rg.name
  common_tags                = var.common_tags
}

module "nfdiv-migration-alert" {
  source            = "git@github.com:hmcts/cnp-module-metric-alert"
  location          = azurerm_application_insights.appinsights.location
  app_insights_name = azurerm_application_insights.appinsights.name

  alert_name                 = "feepay-migration-alert"
  alert_desc                 = "Triggers when a migration fails."
  app_insights_query         = "traces | where message contains \"Setting dataVersion to 0 for case id\" | sort by timestamp desc"
  frequency_in_minutes       = 60
  time_window_in_minutes     = 60
  severity_level             = "1"
  action_group_name          = module.feepay-fail-action-group-slack.action_group_name
  custom_email_subject       = "feepay Migration Failed"
  trigger_threshold_operator = "GreaterThan"
  trigger_threshold          = 0
  resourcegroup_name         = azurerm_resource_group.rg.name
  common_tags                = var.common_tags
}

module "feepay-fail-action-group-slack" {
  source   = "git@github.com:hmcts/cnp-module-action-group"
  location = "global"
  env      = var.env

  resourcegroup_name     = azurerm_resource_group.rg.name
  action_group_name      = "feepay Fail Slack Alert - ${var.env}"
  short_name             = "feepay_slack"
  email_receiver_name    = "feepay Alerts"
  email_receiver_address = "anshika.nigam@hmcts.net"
}
