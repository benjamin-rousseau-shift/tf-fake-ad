terraform {
  backend "azurerm" {
    container_name       = "tfstate"
    key                  = "fakead.tfstate"
    storage_account_name = "theslyfoxtfstate"
    use_azuread_auth     = true
    resource_group_name  = "Infra-sre-preprod"
    subscription_id      = "4d57a08b-6580-4740-8e38-a43f92a60089"
  }
}
