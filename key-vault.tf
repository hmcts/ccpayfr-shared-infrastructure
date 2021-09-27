module "ccpay-vault" {
  source = "git@github.com:hmcts/cnp-module-key-vault?ref=master"
  name = join("-", [var.product, var.env])
  product = var.product
  env = var.env
  tenant_id = var.tenant_id
  object_id = var.jenkins_AAD_objectId
  resource_group_name = azurerm_resource_group.rg.name
  # group id of dcd_reform_dev_azure
  product_group_name = "dcd_group_fees&pay_v2"
  common_tags         = var.common_tags
  #aks migration
  managed_identity_object_ids = ["${var.managed_identity_object_id}"]
  create_managed_identity = true
}

module "feesregister-vault" {
  source = "git@github.com:hmcts/cnp-module-key-vault?ref=master"
  name = join("-", [var.fr_product, var.env])
  product = var.fr_product
  env = var.env
  tenant_id = var.tenant_id
  object_id = var.jenkins_AAD_objectId
  resource_group_name = azurerm_resource_group.rg.name
  # group id of dcd_reform_dev_azure
  product_group_name = "dcd_group_fees&pay_v2"
  common_tags         = var.common_tags
  #aks migration
  managed_identity_object_ids = ["${var.managed_identity_object_id}", "${data.azurerm_user_assigned_identity.ccpay-shared-identity.principal_id}"]
}

data "azurerm_key_vault" "ccpay_key_vault" {
  name                = module.ccpay-vault.key_vault_name
  resource_group_name = azurerm_resource_group.rg.name
}

data "azurerm_user_assigned_identity" "ccpay-shared-identity" {
  name                = "${var.product}-${var.env}-mi"
  resource_group_name = "managed-identities-${var.env}-rg"
}

data "azurerm_key_vault" "s2s_key_vault" {
  name                = local.s2s_key_vault_name
  resource_group_name = local.s2s_vault_resource_group
}

data "azurerm_key_vault_secret" "s2s_secret" {
  name          = "microservicekey-ccpay-cpo-function-node"
  key_vault_id  = data.azurerm_key_vault.s2s_key_vault.id
}

resource "azurerm_key_vault_secret" "ccpay_cpo_s2s_secret" {
  name          = "ccpay-cpo-s2s-secret"
  value         = data.azurerm_key_vault_secret.s2s_secret.value
  key_vault_id  = data.azurerm_key_vault.ccpay_key_vault.id
}

