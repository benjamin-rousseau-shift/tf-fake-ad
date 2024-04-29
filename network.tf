
resource "azurerm_virtual_network" "main" {
  address_space       = [local.address_space, local.vgw_address_space]
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

resource "azurerm_subnet" "vgw" {
  address_prefixes     = [local.vgw_address_space]
  name                 = "GatewaySubnet"
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
  access                      = "Allow"
  direction                   = "Inbound"
  name                        = "AllowMyself"
  network_security_group_name = azurerm_network_security_group.main.name
  priority                    = 100
  protocol                    = "Tcp"
  resource_group_name         = azurerm_resource_group.main.name
  destination_address_prefix  = "*"
  destination_port_range      = "*"
  source_port_range           = "*"
  source_address_prefix       = chomp(data.http.myip.response_body)

}

resource "azurerm_network_security_rule" "allow_eastwest" {
  access                       = "Allow"
  direction                    = "Inbound"
  name                         = "AllowEastWest"
  network_security_group_name  = azurerm_network_security_group.main.name
  priority                     = 101
  protocol                     = "Tcp"
  resource_group_name          = azurerm_resource_group.main.name
  destination_address_prefixes = [local.address_space]
  destination_port_range       = "*"
  source_port_range            = "*"
  source_address_prefixes      = [local.address_space]

}

resource "azurerm_network_security_rule" "allow_ghrunners" {
  access                       = "Allow"
  direction                    = "Inbound"
  name                         = "AllowGithubRunners"
  network_security_group_name  = azurerm_network_security_group.main.name
  priority                     = 102
  protocol                     = "Tcp"
  resource_group_name          = azurerm_resource_group.main.name
  destination_address_prefixes = [local.github_runner_address_space]
  destination_port_range       = "*"
  source_port_range            = "*"
  source_address_prefixes      = [local.github_runner_address_space]

}

resource "azurerm_public_ip" "vgw" {
  allocation_method   = "Static"
  location            = local.address_space
  name                = "sh-az-fake-ad-vpn-ip"
  resource_group_name = azurerm_resource_group.main.name

}

resource "azurerm_virtual_network_gateway" "main" {
  location            = local.location
  name                = "sh-az-fake-ad-vgw"
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "VpnGw1"
  type                = "Vpn"
  vpn_type            = "RouteBased"
  ip_configuration {
    public_ip_address_id = azurerm_public_ip.vgw.id
    subnet_id            = azurerm_subnet.vgw.id
  }

}

resource "azurerm_virtual_network_gateway_connection" "zi_cfr" {
  location                   = local.address_space
  name                       = "fake-ad-to-zi-cfr"
  resource_group_name        = azurerm_resource_group.main.name
  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.main.id
  local_network_gateway_id   = azurerm_local_network_gateway.zi_cfr.id
  shared_key                 = var.ipsec_psk
  dpd_timeout_seconds        = 45
  ipsec_policy {
    dh_group         = "DHGroup2"
    ike_encryption   = "AES256"
    ike_integrity    = "SHA256"
    ipsec_encryption = "AES256"
    ipsec_integrity  = "SHA256"
    pfs_group        = "PFS2"
    sa_lifetime      = 3600
  }
  use_policy_based_traffic_selectors = false
}

resource "azurerm_local_network_gateway" "zi_cfr" {
  name                = "zi-cfr"
  location            = local.location
  resource_group_name = azurerm_resource_group.main.name
  gateway_address     = var.zi_cfr_public_ip
  address_space       = var.zi_cfr_address_spaces

}
