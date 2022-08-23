provider "azurerm" {
  features {}
}

terraform {
  backend "azurerm" {}

  required_version = ">= 1.2.7"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.19.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.3.2"
    }
  }
}
