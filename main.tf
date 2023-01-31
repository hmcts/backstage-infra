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

  enable_read_only_group_access = false
  common_tags                   = module.tags.common_tags
}

module "postgresqlflex" {
  source = "git::https://github.com/hmcts/terraform-module-postgresql-flexible?ref=db-collation"
  env    = var.env

  product       = var.product
  component     = var.component
  name          = "${var.product}-${var.component}"
  business_area = "cft"

  pgsql_databases = [
    {
      name : "backstage_plugin_app"
    },
    {
      name : "backstage_plugin_code-coverage"
    },
    {
      name : "backstage_plugin_auth"
    },
    {
      name : "backstage_plugin_scaffolder"
    },
    {
      name : "backstage_plugin_catalog"
    },
    {
      name : "backstage_plugin_search"
    }
  ]
  pgsql_delegated_subnet_id = data.azurerm_subnet.this.id
  pgsql_version             = "14"

  enable_read_only_group_access = false
  common_tags                   = module.tags.common_tags
}

resource "azurerm_key_vault_secret" "backstage-db-secret" {
  name         = "backstage-db-password"
  value        = module.postgresql.password
  key_vault_id = data.azurerm_key_vault.ptl.id
}

resource "azurerm_key_vault_secret" "backstage-db-secretflex" {
  name         = "backstage-db-passwordflex"
  value        = module.postgresqlflex.password
  key_vault_id = data.azurerm_key_vault.ptl.id
}
