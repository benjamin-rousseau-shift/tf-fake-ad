resource "azurerm_key_vault" "main" {
  location                      = local.location
  name                          = "theslyfoxkeyvault2398"
  resource_group_name           = azurerm_resource_group.main.name
  sku_name                      = "standard"
  tenant_id                     = var.tenant_id
  public_network_access_enabled = true
  enable_rbac_authorization     = true
}

resource "azurerm_role_assignment" "keyvault" {
  principal_id         = var.pipeline_principal_id
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets Officer"

}

resource "random_password" "sftp_accounts" {
  for_each = {
    for k, v in local.sftp_accounts : v => v
  }
  length           = 16
  override_special = "[]_-"

}

resource "azurerm_key_vault_secret" "sftp_accounts" {
  for_each = {
    for k, v in local.sftp_accounts : v => v
  }
  key_vault_id = azurerm_key_vault.main.id
  name         = each.value
  value        = random_password.sftp_accounts[each.value].result

}
