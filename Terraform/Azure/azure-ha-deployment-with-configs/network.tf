resource "azurerm_virtual_network" "transit_vnet" {
  name                = var.transit_vnet_name
  address_space       = var.transit_vnet_prefix
  location            = var.location
  resource_group_name = var.resource_group
  tags                = var.tags
}

resource "azurerm_virtual_network" "data_vnet" {
  name                = var.data_vnet_name
  address_space       = var.data_vnet_prefix
  location            = var.location
  resource_group_name = var.resource_group
  tags                = var.tags
}

resource "azurerm_subnet" "transit_vnet_public_subnet_01" {
  name                 = join("-", [var.transit_vnet_public_subnet_name, "01"])
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.transit_vnet.name
  address_prefixes     = var.transit_vnet_public_subnet_01_prefix

  depends_on = [azurerm_virtual_network.transit_vnet]
}

resource "azurerm_subnet" "transit_vnet_public_subnet_02" {
  name                 = join("-", [var.transit_vnet_public_subnet_name, "02"])
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.transit_vnet.name
  address_prefixes     = var.transit_vnet_public_subnet_02_prefix

  depends_on = [azurerm_virtual_network.transit_vnet]
}

resource "azurerm_subnet" "transit_vnet_private_subnet_01" {
  name                              = join("-", [var.transit_vnet_private_subnet_name, "01"])
  resource_group_name               = var.resource_group
  virtual_network_name              = azurerm_virtual_network.transit_vnet.name
  address_prefixes                  = var.transit_vnet_private_subnet_01_prefix
  private_endpoint_network_policies = "RouteTableEnabled"

  depends_on = [azurerm_virtual_network.transit_vnet]
}

resource "azurerm_subnet" "transit_vnet_private_subnet_02" {
  name                              = join("-", [var.transit_vnet_private_subnet_name, "02"])
  resource_group_name               = var.resource_group
  virtual_network_name              = azurerm_virtual_network.transit_vnet.name
  address_prefixes                  = var.transit_vnet_private_subnet_02_prefix
  private_endpoint_network_policies = "RouteTableEnabled"

  depends_on = [azurerm_virtual_network.transit_vnet]
}

resource "azurerm_subnet" "route_server_subnet" {
  name                              = "RouteServerSubnet"
  resource_group_name               = var.resource_group
  virtual_network_name              = azurerm_virtual_network.transit_vnet.name
  address_prefixes                  = var.route_server_subnet_prefix
  private_endpoint_network_policies = "RouteTableEnabled"

  depends_on = [azurerm_virtual_network.transit_vnet]
}

resource "azurerm_subnet" "data_vnet_public_subnet" {
  name                 = join("-", [var.data_vnet_public_subnet_name])
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.data_vnet.name
  address_prefixes     = var.data_vnet_public_subnet_prefix
}

# Associate the NSG with the Public Subnet
resource "azurerm_subnet_network_security_group_association" "transit_vnet_public_subnet_01_association" {
  subnet_id                 = azurerm_subnet.transit_vnet_public_subnet_01.id
  network_security_group_id = azurerm_network_security_group.public_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "transit_vnet_public_subnet_02_association" {
  subnet_id                 = azurerm_subnet.transit_vnet_public_subnet_02.id
  network_security_group_id = azurerm_network_security_group.public_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "data_vnet_public_subnet_association" {
  subnet_id                 = azurerm_subnet.data_vnet_public_subnet.id
  network_security_group_id = azurerm_network_security_group.public_nsg.id
}

# Associate the NSG with Private Subnet
resource "azurerm_subnet_network_security_group_association" "transit_vnet_priv_subnet_01_association" {
  subnet_id                 = azurerm_subnet.transit_vnet_private_subnet_01.id
  network_security_group_id = azurerm_network_security_group.private_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "transit_vnet_priv_subnet_02_association" {
  subnet_id                 = azurerm_subnet.transit_vnet_private_subnet_02.id
  network_security_group_id = azurerm_network_security_group.private_nsg.id
}

# Peering

resource "azurerm_virtual_network_peering" "data_to_transit" {
  name                      = "data-to-transit"
  resource_group_name       = var.resource_group
  virtual_network_name      = azurerm_virtual_network.data_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.transit_vnet.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  use_remote_gateways          = true

  depends_on = [azurerm_virtual_network.transit_vnet, azurerm_virtual_network.data_vnet]

}

resource "azurerm_virtual_network_peering" "transit_to_data" {
  name                      = "transit-to-data"
  resource_group_name       = var.resource_group
  virtual_network_name      = azurerm_virtual_network.transit_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.data_vnet.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true

  depends_on = [azurerm_virtual_network.transit_vnet, azurerm_virtual_network.data_vnet]

}
