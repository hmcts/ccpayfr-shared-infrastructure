locals {
  subscription_name = "defaultServiceCallbackSubscription"
  retry_queue = "serviceCallbackRetryQueue"
}

module "servicebus-namespace" {
  source              = "git@github.com:hmcts/terraform-module-servicebus-namespace"
  name                = "${var.product}-servicebus-${var.env}"
  location            = var.location
  env                 = var.env
  common_tags         = local.tags
  resource_group_name = azurerm_resource_group.rg.name
}

module "topic" {
  source                = "git@github.com:hmcts/terraform-module-servicebus-topic"
  name                  = "serviceCallbackTopic"
  namespace_name        = module.servicebus-namespace.name
  resource_group_name   = azurerm_resource_group.rg.name
}

module "topic_cpo" {
  source                = "git@github.com:hmcts/terraform-module-servicebus-topic"
  name                  = "ccpay-cpo-Topic"
  namespace_name        = module.servicebus-namespace.name
  resource_group_name   = azurerm_resource_group.rg.name
}

module "queue" {
  source                = "git@github.com:hmcts/terraform-module-servicebus-queue"
  name                  = local.retry_queue
  namespace_name        = module.servicebus-namespace.name
  resource_group_name   = azurerm_resource_group.rg.name
}

module "subscription" {
  source                = "git@github.com:hmcts/terraform-module-servicebus-subscription"
  name                  = local.subscription_name
  namespace_name        = module.servicebus-namespace.name
  topic_name            = module.topic.name
  resource_group_name   = azurerm_resource_group.rg.name
  max_delivery_count    = "1"
  forward_dead_lettered_messages_to = module.queue.name
}

module "subscription_cpo" {
  source                = "git@github.com:hmcts/terraform-module-servicebus-subscription"
  name                  = local.subscription_name
  namespace_name        = module.servicebus-namespace.name
  topic_name            = module.topic_cpo.name
  resource_group_name   = azurerm_resource_group.rg.name
  max_delivery_count    = "1"
  # forward_dead_lettered_messages_to = module.queue.name
}

resource "azurerm_key_vault_secret" "servicebus_primary_connection_string" {
  name      = "sb-primary-connection-string"
  value     = module.servicebus-namespace.primary_send_and_listen_connection_string
  key_vault_id = data.azurerm_key_vault.ccpay_key_vault.id
}

resource "azurerm_key_vault_secret" "cpo-topic-primary-send-listen-shared-access-key" {
  name         = "cpo-topic-primary-send-listen-shared-access-key"
  value        = module.topic_cpo.primary_send_and_listen_shared_access_key
  key_vault_id = data.azurerm_key_vault.ccpay_key_vault.id
}

