resource "azurerm_network_security_group" "VyOS" {
  name                = join("-", [var.prefix, "VyOS", "SG"])
  location            = var.location
  resource_group_name = var.resource_group
  tags                = var.tags

  # For SSH Traffic
  security_rule {
    name                       = "SSH"
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
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "51820"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # For OpenVPN Traffic
  security_rule {
    name                       = "OpenVPN"
    priority                   = 103
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "1194"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # For ESP Traffic
  security_rule {
    name                       = "ESP"
    priority                   = 104
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Esp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # For IKE Traffic
  security_rule {
    name                       = "IKE"
    priority                   = 105
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "500"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # For IPSEC Traffic
  security_rule {
    name                       = "IPSEC"
    priority                   = 106
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "1701"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # For NAT Traversal
  security_rule {
    name                       = "NAT_Traversal"
    priority                   = 107
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "4500"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
