

# --------------------------- VyOS 01 --------------------------------------
# Net 01 VyOS 01 instance 
resource "azurerm_virtual_machine" "net_01_VyOS_01" {
  name                = join("-", [var.prefix, "VyOS", "01"])
  location            = var.location
  resource_group_name = var.resource_group
  vm_size             = var.vm_size
  tags                = var.tags

  network_interface_ids         = [azurerm_network_interface.azure_vnet_01_vyos_01_nic_pub.id, azurerm_network_interface.azure_vnet_01_vyos_01_nic_priv.id]
  primary_network_interface_id  = azurerm_network_interface.azure_vnet_01_vyos_01_nic_pub.id
  delete_os_disk_on_termination = "true"

     plan {
       publisher = var.image_publisher
       name      = var.image_sku
       product   = var.image_offer
     }

  storage_image_reference {
     publisher = var.image_publisher
     offer     = var.image_offer
     sku       = var.image_sku
     version   = var.image_version
  }

  storage_os_disk {
    name              = join("_", [var.prefix, "VyOS", "01", "osdisk"])
    managed_disk_type = "Standard_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

  os_profile {
    computer_name  = join("-", [var.prefix, "VyOS", "01"])
    admin_username = var.admin_username
    admin_password = var.admin_password
    custom_data = base64encode(templatefile("${path.module}/files/vyos_01_user_data.tpl", {
      vnet_01_priv_subnet_prefix = var.vnet_01_priv_subnet_prefix,
      public_ip_address_01       = azurerm_public_ip.azure_vnet_01_public_address.ip_address,
      on_prem_public_ip_address  = var.on_prem_public_ip_address,
      vyos_01_pub_nic_ip         = azurerm_network_interface.azure_vnet_01_vyos_01_nic_pub.private_ip_address,
      vyos_01_priv_nic_ip        = azurerm_network_interface.azure_vnet_01_vyos_01_nic_priv.private_ip_address,
      dns_1                      = var.dns_1,
      dns_2                      = var.dns_2,
      vnet_01_bgp_as_number      = var.vnet_01_bgp_as_number,
      on_prem_bgp_as_number      = var.on_prem_bgp_as_number
    }))
  }

  depends_on = [azurerm_network_interface.azure_vnet_01_vyos_01_nic_priv,
  azurerm_network_interface.azure_vnet_01_vyos_01_nic_pub]

  os_profile_linux_config {
    disable_password_authentication = false
  }
}
