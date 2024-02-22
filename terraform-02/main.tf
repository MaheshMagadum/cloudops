terraform {
  required_version = ">=1.0.0"
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = "~>3.0.0"
    }
  }
}
provider "azurerm" {
  features{}
}

resource "azurerm_resource_group" "rg" {
  name = "dev-rg"
  location = var.location
}