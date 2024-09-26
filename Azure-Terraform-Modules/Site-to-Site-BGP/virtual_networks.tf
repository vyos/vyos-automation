# vNET Creation
resource "azurerm_virtual_network" "azure_vnet_01" {
  name                = join("-", [var.prefix, var.vnet_01_name])
  address_space       = [var.vnet_01_address_prefix]
  location            = var.location
  resource_group_name = var.resource_group
  depends_on = [
    var.resource_group
  ]
  tags = var.tags
}

# Net 01 Subnet Private
resource "azurerm_subnet" "azure_vnet_01_priv_subnet" {
  name                 = join("-", [var.prefix, var.vnet_01_name, "priv"])
  resource_group_name  = var.resource_group
  address_prefixes     = [var.vnet_01_priv_subnet_prefix]
  virtual_network_name = azurerm_virtual_network.azure_vnet_01.name
}

# Net 01 Subnet Public
resource "azurerm_subnet" "azure_vnet_01_pub_subnet" {
  name                 = join("-", [var.prefix, var.vnet_01_name, "pub"])
  resource_group_name  = var.resource_group
  address_prefixes     = [var.vnet_01_pub_subnet_prefix]
  virtual_network_name = azurerm_virtual_network.azure_vnet_01.name
}

# Public Address
resource "azurerm_public_ip" "azure_vnet_01_public_address" {
  name                    = join("-", [var.prefix, var.vnet_01_name, "public", "IP"])
  location                = var.location
  resource_group_name     = var.resource_group
  sku                     = "Standard"
  allocation_method       = "Static"
  idle_timeout_in_minutes = "30"
  tags                    = var.tags
}

# VyOS Route Table
resource "azurerm_route_table" "azure_vnet_01_vyos_01_route" {
  name                          = join("-", [var.prefix, var.vnet_01_name, "VyOS", "01", "route"])
  resource_group_name           = var.resource_group
  location                      = var.location
  disable_bgp_route_propagation = false
  tags                          = var.tags

  route {
    name                   = "Default"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_network_interface.azure_vnet_01_vyos_01_nic_priv.private_ip_address
  }
}

# Assosiate route table to subnet
resource "azurerm_subnet_route_table_association" "azure_vnet_vpn_net_assosiation_01" {
  subnet_id      = azurerm_subnet.azure_vnet_01_priv_subnet.id
  route_table_id = azurerm_route_table.azure_vnet_01_vyos_01_route.id
}

# --------------------------- Network Interface Cards ------------------------

# VyOS-01 Pub-NIC
resource "azurerm_network_interface" "azure_vnet_01_vyos_01_nic_pub" {
  name                 = join("-", [var.prefix, var.vnet_01_name, "VyOS", "01", "pub", "NIC"])
  location             = var.location
  resource_group_name  = var.resource_group
  enable_ip_forwarding = true
  tags                 = var.tags

  ip_configuration {
    name                          = "external-01"
    subnet_id                     = azurerm_subnet.azure_vnet_01_pub_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.azure_vnet_01_public_address.id
  }

  depends_on = [
    azurerm_virtual_network.azure_vnet_01
  ]
}

# VyOS-01 Priv-NIC
resource "azurerm_network_interface" "azure_vnet_01_vyos_01_nic_priv" {
  name                 = join("-", [var.prefix, var.vnet_01_name, "VyOS", "01", "priv", "NIC"])
  location             = var.location
  resource_group_name  = var.resource_group
  enable_ip_forwarding = true
  tags                 = var.tags

  ip_configuration {
    name                          = "internal-01"
    subnet_id                     = azurerm_subnet.azure_vnet_01_priv_subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  depends_on = [
    azurerm_virtual_network.azure_vnet_01
  ]
}

# VyOS 01 Security Group Assosiation
resource "azurerm_network_interface_security_group_association" "azure_vnet_01_vyos_01_pub_attach" {
  network_interface_id      = azurerm_network_interface.azure_vnet_01_vyos_01_nic_pub.id
  network_security_group_id = azurerm_network_security_group.VyOS.id
}
