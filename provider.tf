provider "azurerm" {
  version = "=2.22.0"
  features {}
}

provider "random" {
  version = "=2.2"
}

terraform {
  backend "azurerm" {}
}
