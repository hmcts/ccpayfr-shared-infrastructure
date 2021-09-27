provider "azurerm" {
  features {}
}

locals {
  local_tags_ccpay = {
    "Deployment Environment" = var.env
    "Team Name" = var.team_name
    "Team Contact" = var.team_contact
  }
  tags = merge(var.common_tags, local.local_tags_ccpay)
  vaultName = join("-", [var.core_product, var.env])
  s2sUrl = "http://rpe-service-auth-provider-${var.env}.service.core-compute-${var.env}.internal"
  s2s_rg_prefix               = "rpe-service-auth-provider"
  s2s_key_vault_name          = var.env == "preview" || var.env == "spreview" ? join("-", ["s2s", "aat"]) : join("-", ["s2s", var.env])
  s2s_vault_resource_group    = var.env == "preview" || var.env == "spreview" ? join("-", [local.s2s_rg_prefix, "aat"]) : join("-", [local.s2s_rg_prefix, var.env])
}

resource "azurerm_resource_group" "rg" {
  name     = join("-", [var.product, var.env])
  location = var.location
  tags = local.tags
}
