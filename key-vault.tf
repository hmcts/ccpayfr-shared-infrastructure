module "ccpay-vault" {
  source = "git@github.com:contino/moj-module-key-vault?ref=master"
  name = "${var.product}-${var.env}"
  product = "${var.product}"
  env = "${var.env}"
  tenant_id = "${var.tenant_id}"
  object_id = "${var.jenkins_AAD_objectId}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  # group id of dcd_reform_dev_azure
  product_group_object_id = "56679aaa-b343-472a-bb46-58bbbfde9c3d"
  common_tags         = "${var.common_tags}"
  #aks migration
  managed_identity_object_id = "${var.managed_identity_object_id}"
}
