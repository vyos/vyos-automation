
# Create VyOS instances 
resource "azurerm_virtual_machine" "azure_vpn_net_vyos" {
  count               = 2
  name                = join("-", [var.prefix, "VyOS", "${count.index + 1}"])
  location            = var.location
  resource_group_name = var.resource_group
  vm_size             = var.vm_size

  network_interface_ids         = [azurerm_network_interface.azure_vnet_vpn_net_nic[count.index].id]
  delete_os_disk_on_termination = "true"
  tags                          = var.tags

     plan {
       publisher = var.image_publisher
       name      = var.image_sku
       product   = var.image_offer
     }

  storage_image_reference {
    # id = var.gallery
     publisher = var.image_publisher
     offer     = var.image_offer
     sku       = var.image_sku
     version   = var.image_version
  }

  storage_os_disk {
    name              = join("_", [var.vnet_name, "VyOS", "${count.index + 1}", "osdisk"])
    managed_disk_type = "Standard_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

  os_profile {
    computer_name  = join("-", [var.vnet_name, "VyOS", "${count.index + 1}"])
    admin_username = var.admin_username
    admin_password = var.admin_password
    custom_data = base64encode(templatefile("${path.module}/files/vyos_user_data.tpl", {
      wg_server_subnet_prefix = var.wg_server_subnet_prefix,
      wg_server_Private_IP    = var.wg_server_Private_IP,
      wg_server_port          = var.wg_server_port,
      wg_server_PrivKey       = var.wg_server_PrivKey,
      wg_client_PubKey        = var.wg_client_PublicKey,
      wg_client_PresharedKey  = var.wg_client_PresharedKey,
      dns_1                   = var.dns_1,
      dns_2                   = var.dns_2,
      vyos_number             = count.index + 1
    }))
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

# Generate WireGuard client profile
data "template_file" "wireguard_config" {
  template = file("${path.module}/files/wireguard.tpl")

  vars = {
    wg_client_PrivKey    = var.wg_client_PrivKey
    wg_client_IP         = var.wg_client_IP
    wg_server_Private_IP = var.wg_server_Private_IP
    wg_server_Public_IP  = azurerm_public_ip.azure_vnet_public_address_lb.ip_address
    wg_server_PublicKey  = var.wg_server_PublicKey
    wg_server_port       = var.wg_server_port
    wg_client_PresharedKey = var.wg_client_PresharedKey
  }
}