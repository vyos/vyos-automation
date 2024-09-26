# Management information
output "Admin_Username" {
  value = var.admin_username
}
output "Admin_Password" {
  value = var.admin_password
}

# IP Address configuration
output "VyOS_01_Public_IP_Address" {
  value = azurerm_public_ip.azure_vnet_01_public_address.ip_address
}
