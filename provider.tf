provider "azurerm" {
  version = "=3.19.1"
  features {}
}

provider "random" {
  version = "=3.3.2"
}

terraform {
  backend "azurerm" {}

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
