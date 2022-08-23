provider "azurerm" {
  version = "=3.19.1"
  features {}
}

provider "random" {
  version = "=3.3.2"
}

terraform {
  backend "azurerm" {}
}
