

module "feepay-fail-alert" {
  source            = "git@github.com:hmcts/cnp-module-metric-alert"
  location          = azurerm_application_insights.appinsights.location
  app_insights_name = azurerm_application_insights.appinsights.name

  alert_name                 = "feepay-fail-alert"
  alert_desc                 = "Triggers when an feepay exception is received."
  app_insights_query         = "requests | where toint(resultCode) >= 500 | sort by timestamp desc"

  frequency_in_minutes       = 15
  time_window_in_minutes     = 15
  severity_level             = "3"
  action_group_name          = module.feepay-fail-action-group.action_group_name
  custom_email_subject       = "Alert for 5xx Error "
  trigger_threshold_operator = "GreaterThan"
  trigger_threshold          = 20
  resourcegroup_name         = azurerm_resource_group.rg.name
  common_tags                = var.common_tags
}


module "feepay-fail-action-group" {
  source   = "git@github.com:hmcts/cnp-module-action-group"
  location = "global"
  env      = var.env

  resourcegroup_name     = azurerm_resource_group.rg.name
  action_group_name      = "feepay Fail  Alert - ${var.env}"
  short_name             = "feepay_alert"
  email_receiver_name    = "feepay Alerts"
  email_receiver_address = "anooj.kurup@hmcts.net"
}


