resource "azurerm_resource_group" "main" {
  location = local.location
  name     = "sh-rg-terraform-fake-ad"

}
