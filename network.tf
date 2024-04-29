
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

resource "azurerm_subnet_network_security_group_association" "main" {
  network_security_group_id = azurerm_network_security_group.main.id
  subnet_id                 = azurerm_subnet.main.id

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
  destination_address_prefixes = [local.address_space]
  destination_port_range       = "*"
  source_port_range            = "*"
  source_address_prefixes      = distinct(concat(local.prisma_vpn_public_ips, ["${chomp(data.http.myip.body)}"], local.prims_vpn_private_ips))

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
  destination_address_prefixes = local.github_runner_address_space
  destination_port_range       = "*"
  source_port_range            = "*"
  source_address_prefixes      = local.github_runner_address_space

}

resource "azurerm_network_security_rule" "allow_octopus" {
  access                       = "Allow"
  direction                    = "Inbound"
  name                         = "AllowOctopus"
  network_security_group_name  = azurerm_network_security_group.main.name
  priority                     = 103
  protocol                     = "Tcp"
  resource_group_name          = azurerm_resource_group.main.name
  destination_address_prefixes = [local.address_space]
  destination_port_range       = "10933"
  source_port_range            = "*"
  source_address_prefixes      = ["10.2.3.101/32"]

}

resource "azurerm_network_security_rule" "allow_nagios" {
  access                       = "Allow"
  direction                    = "Inbound"
  name                         = "AllowNagios"
  network_security_group_name  = azurerm_network_security_group.main.name
  priority                     = 104
  protocol                     = "Tcp"
  resource_group_name          = azurerm_resource_group.main.name
  destination_address_prefixes = [local.address_space]
  destination_port_ranges      = ["5693", "161", "162"]
  source_port_range            = "*"
  source_address_prefixes      = ["10.57.5.30/32"]

}

resource "azurerm_network_security_rule" "allow_nagios_icmp" {
  access                       = "Allow"
  direction                    = "Inbound"
  name                         = "AllowOctopusICMP"
  network_security_group_name  = azurerm_network_security_group.main.name
  priority                     = 105
  protocol                     = "Icmp"
  resource_group_name          = azurerm_resource_group.main.name
  destination_address_prefixes = [local.address_space]
  destination_port_range       = "*"
  source_port_range            = "*"
  source_address_prefixes      = ["10.57.5.30/32"]

}

resource "azurerm_network_security_rule" "allow_prometheus" {
  access                       = "Allow"
  direction                    = "Inbound"
  name                         = "AllowPrometheus"
  network_security_group_name  = azurerm_network_security_group.main.name
  priority                     = 106
  protocol                     = "Tcp"
  resource_group_name          = azurerm_resource_group.main.name
  destination_address_prefixes = [local.address_space]
  destination_port_ranges      = ["9091", "9100", "9132", "9142", "9152", "9161", "9162", "9183", "9184", "9185", "9186", "9187", "9188", "9190", "9191"]
  source_port_range            = "*"
  source_address_prefixes      = ["10.61.5.8/32"]

}

resource "azurerm_public_ip" "vgw" {
  allocation_method   = "Static"
  location            = local.location
  name                = "sh-az-fake-ad-vpn-ip"
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"

}

resource "azurerm_virtual_network_gateway" "main" {
  location            = local.location
  name                = "sh-az-fake-ad-vgw"
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "VpnGw2"
  type                = "Vpn"
  vpn_type            = "RouteBased"
  ip_configuration {
    public_ip_address_id = azurerm_public_ip.vgw.id
    subnet_id            = azurerm_subnet.vgw.id
  }

}

resource "azurerm_virtual_network_gateway_connection" "frc1" {
  location                   = local.location
  name                       = "fake-ad-to-frc1"
  resource_group_name        = azurerm_resource_group.main.name
  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.main.id
  local_network_gateway_id   = azurerm_local_network_gateway.frc1.id
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

resource "azurerm_local_network_gateway" "frc1" {
  name                = "frc1"
  location            = local.location
  resource_group_name = azurerm_resource_group.main.name
  gateway_address     = var.frc1_public_ip
  address_space       = distinct(concat(var.frc1_address_spaces, local.github_runner_address_space, local.prims_vpn_private_ips))

}

data "azurerm_virtual_network_gateway" "main" {
  name                = azurerm_virtual_network_gateway.main.name
  resource_group_name = azurerm_virtual_network_gateway.main.resource_group_name
}
