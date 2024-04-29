output "public_ips" {
  value = merge({
    vgw = azurerm_public_ip.vgw.ip_address
    ad  = azurerm_public_ip.ad.ip_address
    },
    {
      for k, v in azurerm_public_ip.vms : k => v.ip_address
    }
  )

}

output "private_ips" {
  value = merge(
    {
      ad = azurerm_network_interface.ad.private_ip_address
    },
    {
      for k, v in azurerm_network_interface.vms : k => v.private_ip_address
    }
  )

}
