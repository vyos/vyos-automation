# Create Load Balancer
resource "azurerm_lb" "azurerm_lb_vyos_vpn_lb" {
  name                = join("-", [var.prefix, "VyOS", "VPN", "Pub", "LB"])
  location            = var.location
  resource_group_name = var.resource_group
  sku                 = "Standard"
  tags                = var.tags

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.azure_vnet_public_address_lb.id
  }
}

resource "azurerm_lb_backend_address_pool" "azure_lb_pool" {
  name            = "BackEndAddressPool"
  loadbalancer_id = azurerm_lb.azurerm_lb_vyos_vpn_lb.id
}

resource "azurerm_lb_probe" "azure_lb_probe" {
  name            = "VyOS_Test"
  loadbalancer_id = azurerm_lb.azurerm_lb_vyos_vpn_lb.id
  port            = 22
}

resource "azurerm_lb_rule" "azure_lb_rule_wireguard" {
  name                           = "WireGuard"
  loadbalancer_id                = azurerm_lb.azurerm_lb_vyos_vpn_lb.id
  protocol                       = "Udp"
  frontend_port                  = var.wg_server_port
  backend_port                   = var.wg_server_port
  frontend_ip_configuration_name = "PublicIPAddress"
  probe_id                       = azurerm_lb_probe.azure_lb_probe.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.azure_lb_pool.id]
  load_distribution              = "SourceIPProtocol"
  enable_floating_ip             = false
  disable_outbound_snat          = true
}

resource "azurerm_network_interface_backend_address_pool_association" "vnet_VyOS" {
  count                   = 2
  network_interface_id    = azurerm_network_interface.azure_vnet_vpn_net_nic[count.index].id
  ip_configuration_name   = "ifconfig-${count.index}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.azure_lb_pool.id
  depends_on              = [azurerm_network_interface.azure_vnet_vpn_net_nic]
}

resource "azurerm_lb_nat_rule" "azure_lb_nat_rule_dns_udp" {
  resource_group_name            = var.resource_group
  loadbalancer_id                = azurerm_lb.azurerm_lb_vyos_vpn_lb.id
  name                           = "DNS-UDP"
  protocol                       = "Udp"
  frontend_port                  = 53
  backend_port                   = 53
  frontend_ip_configuration_name = "PublicIPAddress"
}

resource "azurerm_lb_nat_rule" "azure_lb_nat_rule_dns_tcp" {
  resource_group_name            = var.resource_group
  loadbalancer_id                = azurerm_lb.azurerm_lb_vyos_vpn_lb.id
  name                           = "DNS-TCP"
  protocol                       = "Tcp"
  frontend_port                  = 53
  backend_port                   = 53
  frontend_ip_configuration_name = "PublicIPAddress"
}

resource "azurerm_lb_nat_rule" "azure_lb_nat_rule_http" {
  resource_group_name            = var.resource_group
  loadbalancer_id                = azurerm_lb.azurerm_lb_vyos_vpn_lb.id
  name                           = "HTTP"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
}

resource "azurerm_lb_nat_rule" "azure_lb_nat_rule_https" {
  resource_group_name            = var.resource_group
  loadbalancer_id                = azurerm_lb.azurerm_lb_vyos_vpn_lb.id
  name                           = "HTTPS"
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "PublicIPAddress"
}

resource "azurerm_lb_nat_rule" "azure_lb_nat_rule_ssh" {
  resource_group_name            = var.resource_group
  loadbalancer_id                = azurerm_lb.azurerm_lb_vyos_vpn_lb.id
  name                           = "SSH"
  protocol                       = "Tcp"
  frontend_port_start            = 21
  frontend_port_end              = 22
  backend_port                   = 22
  backend_address_pool_id        = azurerm_lb_backend_address_pool.azure_lb_pool.id
  frontend_ip_configuration_name = "PublicIPAddress"
}

resource "azurerm_lb_outbound_rule" "azurerm_lb_outbound_WG_out" {
  name                    = "OutboundRule"
  loadbalancer_id         = azurerm_lb.azurerm_lb_vyos_vpn_lb.id
  protocol                = "All"
  backend_address_pool_id = azurerm_lb_backend_address_pool.azure_lb_pool.id

  frontend_ip_configuration {
    name = "PublicIPAddress"
  }
}
