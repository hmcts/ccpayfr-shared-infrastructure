

module "servicebus-namespace-premium" {
  providers = {
    azurerm.private_endpoint = azurerm.private_endpoint
  }
  
  source              = "git@github.com:hmcts/terraform-module-servicebus-namespace?ref=master"
  name                = "${var.product}-servicebus-${var.env}"
  location            = var.location
  env                 = var.env
  common_tags         = local.tags
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = var.sku
  zone_redundant      = true
  capacity            = 1

}

module "topic-premium" {
  source                = "git@github.com:hmcts/terraform-module-servicebus-topic?ref=master"
  name                  = "serviceCallbackTopic"
  namespace_name        = module.servicebus-namespace-premium.name
  resource_group_name   = azurerm_resource_group.rg.name
}

module "queue-premium" {
  source                = "git@github.com:hmcts/terraform-module-servicebus-queue?ref=master"
  name                  = local.retry_queue
  namespace_name        = module.servicebus-namespace-premium.name
  resource_group_name   = azurerm_resource_group.rg.name
}

module "subscription-premium" {
  source                = "git@github.com:hmcts/terraform-module-servicebus-subscription?ref=master"
  name                  = local.subscription_name
  namespace_name        = module.servicebus-namespace-premium.name
  topic_name            = module.topic-premium.name
  resource_group_name   = azurerm_resource_group.rg.name
  max_delivery_count    = "1"
  forward_dead_lettered_messages_to = module.queue-premium.name
}



resource "azurerm_key_vault_secret" "servicebus_primary_connection_string-premium" {
  name         = "sb-primary-connection-string"
  value        = module.servicebus-namespace-premium.primary_send_and_listen_connection_string
  key_vault_id = data.azurerm_key_vault.ccpay_key_vault.id
}

# primary connection string for send and listen operations
output "sb_primary_send_and_listen_connection_string-premium" {
  value     = module.servicebus-namespace-premium.primary_send_and_listen_connection_string
  sensitive = true
}

output "topic_primary_send_and_listen_connection_string-premium" {
  value     = module.topic-premium.primary_send_and_listen_connection_string
  sensitive = true
}

output "psc_subscription_connection_string-premium" {
  value     = "${module.topic.primary_send_and_listen_connection_string}/subscriptions/${local.subscription_name}"
  sensitive = true
}
