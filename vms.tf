resource "azurerm_public_ip" "vms" {
  for_each = {
    for k, v in local.vm_to_deploy : v.name => v
  }
  allocation_method   = "Dynamic"
  location            = local.location
  name                = "sh-az-fake-${each.value.name}-pip"
  resource_group_name = azurerm_resource_group.main.name

}

resource "azurerm_network_interface" "vms" {
  for_each = {
    for k, v in local.vm_to_deploy : v.name => v
  }
  location            = local.location
  name                = "sh-az-fake-${each.value.name}-nic"
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(local.address_space, each.value.hostnumber)
    public_ip_address_id          = azurerm_public_ip.vms[each.key].id
    primary                       = true

  }

}

resource "azurerm_windows_virtual_machine" "vms" {
  for_each = {
    for k, v in local.vm_to_deploy : v.name => v
  }
  admin_password        = var.admin_password
  admin_username        = var.admin_username
  location              = local.location
  name                  = "sh-az-fake-${each.value.name}"
  network_interface_ids = [azurerm_network_interface.vms[each.key].id]
  resource_group_name   = azurerm_resource_group.main.name
  size                  = "Standard_D2as_v4"
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
  computer_name = "sh-az-fake-${each.value.name}"
}
