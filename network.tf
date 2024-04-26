
resource "azurerm_virtual_network" "main" {
  address_space       = [local.address_space]
  location            = local.location
  name                = "vnet-terraform-fake-ad"
  resource_group_name = azurerm_resource_group.main.name

}

resource "azurerm_subnet" "main" {
  address_prefixes     = [local.address_space]
  name                 = "subnet-terraform-fake-ad"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name

}

resource "azurerm_network_security_group" "main" {
  location            = local.location
  name                = "subnet-terraform-fake-ad-nsg"
  resource_group_name = azurerm_resource_group.main.name

}

data "http" "myip" {
  url = "https://ipv4.icanhazip.com"
}

resource "azurerm_network_security_rule" "allow_myself" {
  access                       = "Allow"
  direction                    = "Inbound"
  name                         = "AllowMyself"
  network_security_group_name  = azurerm_network_security_group.main.name
  priority                     = 100
  protocol                     = "Tcp"
  resource_group_name          = azurerm_resource_group.main.name
  destination_address_prefixes = ["*"]
  destination_port_ranges      = ["*"]
  source_address_prefix        = chomp(data.http.myip.response_body)

}

resource "azurerm_network_security_rule" "allow_eastwest" {
  access                       = "Allow"
  direction                    = "Inbound"
  name                         = "AllowEastWest"
  network_security_group_name  = azurerm_network_security_group.main.name
  priority                     = 100
  protocol                     = "Tcp"
  resource_group_name          = azurerm_resource_group.main.name
  destination_address_prefixes = [local.address_space]
  destination_port_ranges      = ["*"]
  source_address_prefixes      = [local.address_space]

}
