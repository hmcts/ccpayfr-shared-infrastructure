module "ccpay-vault" {
  source              = "git@github.com:hmcts/cnp-module-key-vault?ref=master"
  name                = join("-", [var.product, var.env])
  product             = var.product
  env                 = var.env
  tenant_id           = var.tenant_id
  object_id           = var.jenkins_AAD_objectId
  resource_group_name = azurerm_resource_group.rg.name
  # group id of dcd_reform_dev_azure
  product_group_name = "dcd_group_fees&pay_v2"
  common_tags        = var.common_tags
  create_managed_identity     = true
}

module "feesregister-vault" {
  source              = "git@github.com:hmcts/cnp-module-key-vault?ref=master"
  name                = join("-", [var.fr_product, var.env])
  product             = var.fr_product
  env                 = var.env
  tenant_id           = var.tenant_id
  object_id           = var.jenkins_AAD_objectId
  resource_group_name = azurerm_resource_group.rg.name
  # group id of dcd_reform_dev_azure
  product_group_name = "dcd_group_fees&pay_v2"
  common_tags        = var.common_tags
  managed_identity_object_ids = ["${data.azurerm_user_assigned_identity.ccpay-shared-identity.principal_id}"]
}

data "azurerm_key_vault" "ccpay_key_vault" {
  name                = module.ccpay-vault.key_vault_name
  resource_group_name = azurerm_resource_group.rg.name
}

data "azurerm_user_assigned_identity" "ccpay-shared-identity" {
  name                = "${var.product}-${var.env}-mi"
  resource_group_name = "managed-identities-${var.env}-rg"
}

