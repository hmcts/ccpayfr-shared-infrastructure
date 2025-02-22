locals {
  subscription_name_premium    = "serviceCallbackPremiumSubscription"
  service_callback_topic       = "ccpay-service-callback-topic"
  service_callback_retry_queue = "ccpay-service-callback-retry-queue"
}

module "servicebus-namespace-premium" {
  providers = {
    azurerm.private_endpoint = azurerm.private_endpoint
  }

  source              = "git@github.com:hmcts/terraform-module-servicebus-namespace?ref=4.x"
  name                = "${var.product}-servicebus-${var.env}-premium"
  location            = var.location
  env                 = var.env
  common_tags         = local.tags
  sku                 = var.service_bus_sku
  resource_group_name = azurerm_resource_group.rg.name
}

module "topic-premium" {
  source              = "git@github.com:hmcts/terraform-module-servicebus-topic?ref=4.x"
  name                = local.service_callback_topic
  namespace_name      = module.servicebus-namespace-premium.name
  resource_group_name = azurerm_resource_group.rg.name

  depends_on = [module.servicebus-namespace-premium]
}

module "queue-premium" {
  source              = "git@github.com:hmcts/terraform-module-servicebus-queue?ref=4.x"
  name                = local.service_callback_retry_queue
  namespace_name      = module.servicebus-namespace-premium.name
  resource_group_name = azurerm_resource_group.rg.name

  depends_on = [module.servicebus-namespace-premium]
}

module "subscription-premium" {
  source                            = "git@github.com:hmcts/terraform-module-servicebus-subscription?ref=4.x"
  name                              = local.subscription_name_premium
  topic_name                        = module.topic-premium.name
  namespace_id                      = module.servicebus-namespace-premium.id
  max_delivery_count                = "1"
  forward_dead_lettered_messages_to = module.queue-premium.name

  depends_on = [module.topic-premium]
}

resource "azurerm_key_vault_secret" "servicebus_premium_primary_connection_string" {
  name         = "sb-premium-primary-connection-string"
  value        = module.servicebus-namespace-premium.primary_send_and_listen_connection_string
  key_vault_id = data.azurerm_key_vault.ccpay_key_vault.id

  depends_on = [module.servicebus-namespace-premium]
}

# primary connection string for send and listen operations
output "sb_premium_primary_send_and_listen_connection_string" {
  value     = module.servicebus-namespace-premium.primary_send_and_listen_connection_string
  sensitive = true
}

output "topic_premium_primary_send_and_listen_connection_string" {
  value     = module.topic-premium.primary_send_and_listen_connection_string
  sensitive = true
}

output "psc_premium_subscription_connection_string" {
  value     = "${module.topic-premium.primary_send_and_listen_connection_string}/subscriptions/${local.subscription_name_premium}"
  sensitive = true
}

