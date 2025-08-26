resource "azurerm_virtual_network" "test_vnet" {
  name                = var.vnet_name
  address_space       = var.vnet_prefix
  location            = var.location
  resource_group_name = var.resource_group
  tags                = var.tags
}

resource "azurerm_subnet" "test_vnet_public" {
  name                 = var.public_subnet_name
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.test_vnet.name
  address_prefixes     = var.public_subnet_prefix
}

resource "azurerm_subnet" "test_vnet_private" {
  name                              = var.private_subnet_name
  resource_group_name               = var.resource_group
  virtual_network_name              = azurerm_virtual_network.test_vnet.name
  address_prefixes                  = var.private_subnet_prefix
  private_endpoint_network_policies = "RouteTableEnabled"
}

# Associate the NSG with the Public Subnet
resource "azurerm_subnet_network_security_group_association" "public_association" {
  subnet_id                 = azurerm_subnet.test_vnet_public.id
  network_security_group_id = azurerm_network_security_group.public_nsg.id
}

# Associate the NSG with Private Subnet
resource "azurerm_subnet_network_security_group_association" "private_association" {
  subnet_id                 = azurerm_subnet.test_vnet_private.id
  network_security_group_id = azurerm_network_security_group.private_nsg.id
}

## Route Tables

resource "azurerm_route_table" "ubuntu_vm_priv_subnet_route" {
  name                          = "ubuntu_vm_priv_subnet_route"
  location                      = var.location
  resource_group_name           = var.resource_group
  bgp_route_propagation_enabled = false

  route {
    name                   = "DefaultRoute"
    address_prefix         = var.aws_subnet_cidr
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_network_interface.vyos_priv_nic.private_ip_address
  }

  tags = var.tags
}

resource "azurerm_subnet_route_table_association" "ubuntu_vm_priv_subnet_route_association" {
  subnet_id      = azurerm_subnet.test_vnet_private.id
  route_table_id = azurerm_route_table.ubuntu_vm_priv_subnet_route.id
}
