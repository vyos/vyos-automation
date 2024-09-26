resource "azurerm_network_security_group" "azure_sg_vyos" {
  name                = join("-", [var.prefix, "VyOS", "SG"])
  location            = var.location
  resource_group_name = var.resource_group
  tags                = var.tags

  # For SSH Traffic
  security_rule {
    name                       = "SSH-VyOS"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # For Wireguard Traffic
  security_rule {
    name                       = "Wireguard"
    priority                   = 103
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "51820"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}