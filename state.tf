terraform {
  backend "azurerm" {}
}

data "azurerm_subnet" "subnet_a" {
  name                 = join("-",["core-infra-subnet-0" , var.env])
  virtual_network_name = join("-",["core-infra-vnet" , var.env])
  resource_group_name  = join("-",["core-infra" , var.env])
}
