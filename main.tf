resource "azurerm_resource_group" "rg" {
  name     = "incident-backstage-rg"
  location = "UK South"

  tags = module.tags.common_tags
}

resource "random_password" "password" {
  length  = 16
  special = true
  upper   = true
  lower   = true
  number  = true
}

locals {
  key_vault_name = var.env == "ptlsbox" ? "cftsbox-intsvc" : "cftptl-intsvc"
  old_vnet_name  = var.env == "ptlsbox" ? "core-cftsbox-intsvc-vnet" : "core-cftptl-intsvc-vnet"
  old_vnet_rg    = var.env == "ptlsbox" ? "aks-infra-cftsbox-intsvc-rg" : "aks-infra-cftptl-intsvc-rg"

  old_env = var.env == "ptlsbox" ? "sbox" : var.env
}

data "azurerm_key_vault" "ptl" {
  name                = local.key_vault_name
  resource_group_name = "core-infra-intsvc-rg"
}

resource "azurerm_postgresql_server" "db" {
  name                = "hmcts-backstage-${local.old_env}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  administrator_login          = "backstage"
  administrator_login_password = random_password.password.result

  sku_name   = "GP_Gen5_2"
  version    = "11"
  storage_mb = 5120

  backup_retention_days = 7

  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_2"

  tags = module.tags.common_tags
}

resource "azurerm_postgresql_database" "backstage_plugin_catalog" {
  name                = "backstage_plugin_catalog"
  resource_group_name = azurerm_postgresql_server.db.resource_group_name
  server_name         = azurerm_postgresql_server.db.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

resource "azurerm_postgresql_database" "backstage_plugin_auth" {
  name                = "backstage_plugin_auth"
  resource_group_name = azurerm_postgresql_server.db.resource_group_name
  server_name         = azurerm_postgresql_server.db.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

data "azurerm_subnet" "subnet-00" {
  name                 = "aks-00"
  resource_group_name  = local.old_vnet_rg
  virtual_network_name = local.old_vnet_name
}

resource "azurerm_postgresql_virtual_network_rule" "cluster-access" {
  name                = "aks-00"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_postgresql_server.db.name
  subnet_id           = data.azurerm_subnet.subnet-00.id
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
  source = "git::https://github.com/hmcts/terraform-module-postgresql-flexible?ref=make-subnet-flexible"
  env    = var.env

  product   = var.product
  component = var.component
  name      = "${var.product}-${var.component}-flex"
  project   = "cft"

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

  common_tags = module.tags.common_tags
}

resource "azurerm_key_vault_secret" "backstage-db-secret" {
  name         = "backstage-db-password"
  value        = module.postgresql.password
  key_vault_id = data.azurerm_key_vault.ptl.id
}
