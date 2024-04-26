resource "azurerm_public_ip" "ad" {
  allocation_method   = "Dynamic"
  location            = local.location
  name                = "sh-az-fake-ad1-pip"
  resource_group_name = azurerm_resource_group.main.name

}

resource "azurerm_network_interface" "ad" {
  location            = local.location
  name                = "sh-az-fake-ad1-nic"
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(local.address_space, 4)
    public_ip_address_id          = azurerm_public_ip.ad.id
    primary                       = true

  }

}

resource "azurerm_windows_virtual_machine" "ad" {
  admin_password        = var.admin_password
  admin_username        = var.admin_username
  location              = local.location
  name                  = "sh-az-fake-ad1"
  network_interface_ids = [azurerm_network_interface.ad.id]
  resource_group_name   = azurerm_resource_group.main.name
  size                  = "Standard_D4s_v3"
  os_disk {
    caching              = "None"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    offer     = "WindowsServer"
    publisher = "MicrosoftWindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }
  computer_name = "sh-az-fake-ad1"
}
