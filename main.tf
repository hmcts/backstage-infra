locals {
  key_vault_name = var.env == "ptlsbox" ? "cftsbox-intsvc" : "cftptl-intsvc"
}

data "azurerm_key_vault" "ptl" {
  name                = local.key_vault_name
  resource_group_name = "core-infra-intsvc-rg"
}

data "azurerm_subnet" "this" {
  name                 = "postgresql"
  resource_group_name  = "cft-${var.env}-network-rg"
  virtual_network_name = "cft-${var.env}-vnet"
}

module "tags" {
  source      = "git::https://github.com/hmcts/terraform-module-common-tags?ref=master"
  builtFrom   = var.builtFrom
  environment = var.env
  product     = "cft-platform"
}

module "postgresql" {
  count = var.env == "ptl" ? 1 : 0
  providers = {
    azurerm.postgres_network = azurerm.postgres_network
  }

  source = "git::https://github.com/hmcts/terraform-module-postgresql-flexible?ref=master"
  env    = var.env

  product       = var.product
  component     = var.component
  name          = "${var.product}-${var.component}-flex"
  business_area = "cft"

  pgsql_databases = [
    {
      name : "backstage_plugin_catalog"
    },
    {
      name : "backstage_plugin_auth"
    },
  ]
  pgsql_delegated_subnet_id = data.azurerm_subnet.this.id
  pgsql_version             = "14"

  # https://github.com/hmcts/terraform-module-postgresql-flexible/pull/28 changes collation to en_GB
  # setting to en_US means we can skip migrating the data as the collation here doesn't matter much
  collation = "en_US.utf8"

  enable_read_only_group_access = false
  common_tags                   = module.tags.common_tags
}

resource "azurerm_key_vault_secret" "backstage-db-secret" {
  count        = var.env == "ptl" ? 1 : 0
  name         = "backstage-db-password"
  value        = module.postgresql.password[count.index]
  key_vault_id = data.azurerm_key_vault.ptl.id
}
