resource "azurerm_application_insights" "appinsights" {
  name                = join("-", [var.product, var.env])
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = var.application_type
  tags                = local.tags

  lifecycle {
    ignore_changes = [
      # Ignore changes to appinsights as otherwise upgrading to the Azure provider 2.x
      # destroys and re-creates this appinsights instance
      application_type,
    ]
  }
}