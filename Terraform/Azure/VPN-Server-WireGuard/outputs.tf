# Management information

output "Admin_Username" {
  value = var.admin_username
}

output "Admin_Password" {
  value = var.admin_password
}

# IP Address configuration

output "VPN_Server_Public_IP_Address" {
  value = azurerm_public_ip.azure_vnet_public_address_lb.ip_address
}

output "VyOS_01_Private_IP_Address" {
  value = azurerm_network_interface.azure_vnet_vpn_net_nic[0].private_ip_address
}

output "VyOS_02_Private_IP_Address" {
  value = azurerm_network_interface.azure_vnet_vpn_net_nic[1].private_ip_address
}

# VPN Client Profiles

resource "local_file" "wireguard_profile" {
  filename = "${path.module}/profiles/wireguard_profile.conf"
  content  = data.template_file.wireguard_config.rendered
}