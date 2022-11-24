provider "azurerm" {
  features {}
}

terraform {
  backend "azurerm" {}

  required_version = ">= 1.3.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.33.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.3.2"
    }
  }
}
