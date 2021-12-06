terraform {
  backend "azurerm" {}

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.25"
    }
    
    azuread = {
      source  = "hashicorp/azuread"
      version = "1.6.0"
    }
  }
}

data "azurerm_subnet" "subnet_a" {
  name                 = join("-",["core-infra-subnet-0" , var.env])
  virtual_network_name = join("-",["core-infra-vnet" , var.env])
  resource_group_name  = join("-",["core-infra" , var.env])
}
