# Public IPs for VyOS and route-server
resource "azurerm_public_ip" "vyos_rs_ip" {
  name                = "vyos_rs_ip"
  resource_group_name = var.resource_group
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_subnet" "vyos_rs" {
  name = "RouteServerSubnet"

  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.transit_vnet.name
  address_prefixes     = var.route_server_subnet_prefix
  depends_on           = [azurerm_virtual_network.transit_vnet]
}

resource "azurerm_route_server" "azure_rs" {
  name                             = "azure_rs"
  resource_group_name              = var.resource_group
  location                         = var.location
  sku                              = "Standard"
  public_ip_address_id             = azurerm_public_ip.vyos_rs_ip.id
  subnet_id                        = azurerm_subnet.vyos_rs.id
  branch_to_branch_traffic_enabled = true
  tags                             = var.tags
}

resource "azurerm_route_server_bgp_connection" "rs_bgp_vyos_01" {
  name            = "rs_bgp_vyos_01"
  route_server_id = azurerm_route_server.azure_rs.id
  peer_asn        = var.vyos_bgp_as_number
  peer_ip         = azurerm_network_interface.vyos_01_priv_nic.private_ip_address
}

resource "azurerm_route_server_bgp_connection" "rs_bgp_vyos_02" {
  name            = "rs_bgp_vyos_02"
  route_server_id = azurerm_route_server.azure_rs.id
  peer_asn        = var.vyos_bgp_as_number
  peer_ip         = azurerm_network_interface.vyos_02_priv_nic.private_ip_address
}
