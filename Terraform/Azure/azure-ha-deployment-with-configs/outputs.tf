output "vyos_01_public_ip" {
  value = azurerm_public_ip.vyos_01_vm_public_ip.ip_address
}

output "vyos_02_public_ip" {
  value = azurerm_public_ip.vyos_02_vm_public_ip.ip_address
}

output "ubuntu_vm_public_ip" {
  value = azurerm_public_ip.ubuntu_vm_public_ip.ip_address
}

output "admin_username" {
  value = var.admin_username
}

output "admin_password" {
  value     = var.admin_password
  sensitive = true
}

output "ssh_command_vyos_01_vm" {
  value = "ssh -i keys/id_rsa ${var.admin_username}@${azurerm_public_ip.vyos_01_vm_public_ip.ip_address}"
}

output "ssh_command_vyos_02_vm" {
  value = "ssh -i keys/id_rsa ${var.admin_username}@${azurerm_public_ip.vyos_02_vm_public_ip.ip_address}"
}

output "ssh_command_ubuntu_vm" {
  value = "ssh -i keys/id_rsa ${var.admin_username}@${azurerm_public_ip.ubuntu_vm_public_ip.ip_address}"
}

output "route_server_ips" {
  value       = azurerm_route_server.azure_rs.virtual_router_ips
  description = "Azure Route Server BGP peer IPs"
}
