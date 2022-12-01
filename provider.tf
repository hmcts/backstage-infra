provider "azurerm" {
  features {}
}

terraform {
  backend "azurerm" {}

  required_version = ">= 1.3.5"

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.3.2"
    }
  }
}
