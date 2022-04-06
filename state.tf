terraform {
  backend "azurerm" {}

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.25"
    }
  }
}

data "azurerm_subnet" "subnet_a" {
  name                 = join("-",["core-infra-subnet-0" , var.env])
  virtual_network_name = join("-",["core-infra-vnet" , var.env])
  resource_group_name  = join("-",["core-infra" , var.env])
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
  alias                      = "private-endpoint"
  subscription_id            = var.aks_subscription_id
}
