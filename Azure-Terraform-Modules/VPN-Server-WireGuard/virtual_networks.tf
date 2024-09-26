# vNET Creation
resource "azurerm_virtual_network" "azure_vnet_vpn_net" {
  name                = var.vnet_name
  address_space       = [var.vnet_address_prefix]
  location            = var.location
  resource_group_name = var.resource_group
  depends_on = [
    var.resource_group
  ]
  tags = var.tags
}

# vNet Subnet Public
resource "azurerm_subnet" "azure_vnet_pub_subnet" {
  name                 = join("-", [var.prefix, var.vnet_name, "pub"])
  resource_group_name  = var.resource_group
  address_prefixes     = [var.vnet_pub_subnet_prefix]
  virtual_network_name = azurerm_virtual_network.azure_vnet_vpn_net.name
}

# vNet Subnet Wire Guard
resource "azurerm_subnet" "azure_vnet_priv_subnet" {
  name                 = join("-", [var.prefix, var.vnet_name, "priv-wg"])
  resource_group_name  = var.resource_group
  address_prefixes     = [var.wg_server_subnet_prefix]
  virtual_network_name = azurerm_virtual_network.azure_vnet_vpn_net.name
}

# Public Address
resource "azurerm_public_ip" "azure_vnet_public_address_lb" {
  name                    = join("-", [var.prefix, var.vnet_name, "VPN", "LB", "public", "IP"])
  location                = var.location
  resource_group_name     = var.resource_group
  sku                     = "Standard"
  allocation_method       = "Static"
  idle_timeout_in_minutes = "30"
  tags                    = var.tags
}

# VyOS Route Table
resource "azurerm_route_table" "azure_vnet_vpn_net_VyOS_route" {
  name                          = join("-", [var.prefix, var.vnet_name, "VyOS", "route"])
  resource_group_name           = var.resource_group
  location                      = var.location
  disable_bgp_route_propagation = false
  tags                          = var.tags

  route {
    name                   = "Default"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.wg_server_Private_IP
  }
}

# Assosiate route table to subnet
resource "azurerm_subnet_route_table_association" "azure_vnet_vpn_net_assosiation" {
  subnet_id      = azurerm_subnet.azure_vnet_priv_subnet.id
  route_table_id = azurerm_route_table.azure_vnet_vpn_net_VyOS_route.id
}

# Create NIC for VyOS
resource "azurerm_network_interface" "azure_vnet_vpn_net_nic" {
  count                = 2
  name                 = join("-", [var.prefix, var.vnet_name, "VyOS", "${count.index}", "NIC"])
  location             = var.location
  resource_group_name  = var.resource_group
  enable_ip_forwarding = true
  tags                 = var.tags

  ip_configuration {
    name                          = "ifconfig-${count.index}"
    subnet_id                     = azurerm_subnet.azure_vnet_pub_subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  depends_on = [
    azurerm_virtual_network.azure_vnet_vpn_net
  ]
}

# VyOS Security Group Assosiation
resource "azurerm_network_interface_security_group_association" "vpn_net_VyOS_attach" {
  count                     = 2
  network_interface_id      = azurerm_network_interface.azure_vnet_vpn_net_nic[count.index].id
  network_security_group_id = azurerm_network_security_group.azure_sg_vyos.id
  depends_on                = [azurerm_network_security_group.azure_sg_vyos]
}
