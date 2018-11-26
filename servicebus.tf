locals {
  subscription_name = "defaultServiceCallbackSubscription"
}

module "servicebus-namespace" {
  source              = "git@github.com:hmcts/terraform-module-servicebus-namespace.git"
  name                = "${var.product}-servicebus-${var.env}"
  location            = "${var.location}"
  env                 = "${var.env}"
  common_tags         = "${var.common_tags}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
}

module "topic" {
  source                = "git@github.com:hmcts/terraform-module-servicebus-topic.git"
  name                  = "serviceCallbackTopic"
  namespace_name        = "${module.servicebus-namespace.name}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
}
  
module "subscription" {
  source                = "git@github.com:hmcts/terraform-module-servicebus-subscription.git"
  name                  = "${local.subscription_name}"
  namespace_name        = "${module.servicebus-namespace.name}"
  topic_name            = "${module.topic.name}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
}

resource "azurerm_key_vault_secret" "servicebus_primary_connection_string" {
  name      = "sb-primary-connection-string"
  value     = "${module.servicebus-namespace.primary_send_and_listen_connection_string}"
  vault_uri = "${module.ccpay-vault.key_vault_uri}"
}

# primary connection string for send and listen operations
output "sb_primary_send_and_listen_connection_string" {
  value = "${module.servicebus-namespace.primary_send_and_listen_connection_string}"
}

# secondary connection string for send and listen operations
output "sb_secondary_send_and_listen_connection_string" {
  value = "${module.servicebus-namespace.secondary_send_and_listen_connection_string}"
}

output "topic_primary_send_and_listen_connection_string" {
  value = "${module.topic.primary_send_and_listen_connection_string}"
}

output "psc_subscription_connection_string" {
  value = "${module.topic.primary_send_and_listen_connection_string}/subscriptions/${local.subscription_name}"
}
