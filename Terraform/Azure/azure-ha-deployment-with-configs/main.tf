
# Public IP for VyOS 01 VM
resource "azurerm_public_ip" "vyos_01_vm_public_ip" {
  name                    = "vyos-01-vm-public-ip"
  location                = var.location
  resource_group_name     = var.resource_group
  allocation_method       = "Static"
  sku                     = "Standard"
  tags                    = var.tags
  idle_timeout_in_minutes = "30"

  timeouts {
    create = "15m"
    delete = "10m"
  }
}

# Public IP for VyOS 02 VM
resource "azurerm_public_ip" "vyos_02_vm_public_ip" {
  name                    = "vyos-02-vm-public-ip"
  location                = var.location
  resource_group_name     = var.resource_group
  allocation_method       = "Static"
  sku                     = "Standard"
  tags                    = var.tags
  idle_timeout_in_minutes = "30"

  timeouts {
    create = "15m"
    delete = "10m"
  }
}

# # Public IP for Ubuntu VM
resource "azurerm_public_ip" "ubuntu_vm_public_ip" {
  name                    = "Ubuntu-VM-Public-IP"
  location                = var.location
  resource_group_name     = var.resource_group
  allocation_method       = "Static"
  sku                     = "Standard"
  tags                    = var.tags
  idle_timeout_in_minutes = "30"

}

# VyOS 01 Public NIC
resource "azurerm_network_interface" "vyos_01_pub_nic" {
  name                = "vyos-01-pub-nic"
  location            = var.location
  resource_group_name = var.resource_group
  tags                = var.tags

  ip_configuration {
    name                          = "vyos-01-public"
    subnet_id                     = azurerm_subnet.transit_vnet_public_subnet_01.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.vyos_01_public_nic_ip_address
    public_ip_address_id          = azurerm_public_ip.vyos_01_vm_public_ip.id
  }

  timeouts {
    create = "10m"
    delete = "10m"
  }
}

# VyOS 01 Private NIC
resource "azurerm_network_interface" "vyos_01_priv_nic" {
  name                = "vyos-01-priv-nic"
  location            = var.location
  resource_group_name = var.resource_group
  tags                = var.tags

  ip_forwarding_enabled          = true
  accelerated_networking_enabled = true

  ip_configuration {
    name                          = "vyos-01-private"
    subnet_id                     = azurerm_subnet.transit_vnet_private_subnet_01.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.vyos_01_priv_nic_ip_address
  }

  timeouts {
    create = "10m"
    delete = "10m"
  }
}

# VyOS 02 Public NIC
resource "azurerm_network_interface" "vyos_02_pub_nic" {
  name                = "vyos-02-pub-nic"
  location            = var.location
  resource_group_name = var.resource_group
  tags                = var.tags

  ip_configuration {
    name                          = "vyos-02-public"
    subnet_id                     = azurerm_subnet.transit_vnet_public_subnet_02.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.vyos_02_public_nic_ip_address
    public_ip_address_id          = azurerm_public_ip.vyos_02_vm_public_ip.id
  }

  timeouts {
    create = "10m"
    delete = "10m"
  }
}

# VyOS 01 Private NIC
resource "azurerm_network_interface" "vyos_02_priv_nic" {
  name                = "vyos-02-priv-nic"
  location            = var.location
  resource_group_name = var.resource_group
  tags                = var.tags

  ip_forwarding_enabled          = true
  accelerated_networking_enabled = true

  ip_configuration {
    name                          = "vyos-02-private"
    subnet_id                     = azurerm_subnet.transit_vnet_private_subnet_02.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.vyos_02_priv_nic_ip_address
  }

  timeouts {
    create = "10m"
    delete = "10m"
  }
}

locals {
  route_server_ips = tolist(azurerm_route_server.azure_rs.virtual_router_ips)
}

# Public NIC for Ubuntu VM 

resource "azurerm_network_interface" "ubuntu_vm_pub_nic" {
  name                = "ubuntu-vm-pub-nic"
  location            = var.location
  resource_group_name = var.resource_group
  tags                = var.tags

  ip_configuration {
    name                          = "ubuntu-public"
    subnet_id                     = azurerm_subnet.data_vnet_public_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ubuntu_vm_public_ip.id
  }

}

# VyOS 01 virtual machine parameters
resource "azurerm_linux_virtual_machine" "vyos_01_vm" {
  name                = "vyos-vm-01"
  location            = var.location
  resource_group_name = var.resource_group
  size                = var.vyos_vm_size
  tags                = var.tags

  network_interface_ids = [
    azurerm_network_interface.vyos_01_pub_nic.id,
    azurerm_network_interface.vyos_01_priv_nic.id
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.public_key)
  }

  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false


  custom_data = base64encode(templatefile("${path.module}/files/vyos_01_user_data.tpl", {
    vyos_01_priv_subnet   = var.transit_vnet_private_subnet_01_prefix[0],
    vyos_01_pub_nic_ip    = azurerm_network_interface.vyos_01_pub_nic.private_ip_address,
    vyos_01_priv_nic_ip   = azurerm_network_interface.vyos_01_priv_nic.private_ip_address,
    vyos_01_bgp_as_number = var.vyos_bgp_as_number,
    route_server_ip_01    = local.route_server_ips[0],
    route_server_ip_02    = local.route_server_ips[1],
    dns                   = var.dns,
    on_prem_pub_ip        = var.on_prem_pub_ip,
    on_prem_bgp_as_number = var.on_prem_bgp_as_number,
    data_vnet_subnet      = var.data_vnet_public_subnet_prefix[0]
  }))

  os_disk {
    name                 = "vyos-vm-01-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  plan {
    name      = var.image_sku
    publisher = var.image_publisher
    product   = var.image_offer
  }

  depends_on = [
    azurerm_network_interface.vyos_01_pub_nic,
    azurerm_network_interface.vyos_01_priv_nic,
    azurerm_public_ip.vyos_01_vm_public_ip
  ]

  timeouts {
    create = "60m"
    update = "30m"
    delete = "30m"
  }
}

# VyOS 02 virtual machine parameters
resource "azurerm_linux_virtual_machine" "vyos_02_vm" {
  name                = "vyos-vm-02"
  location            = var.location
  resource_group_name = var.resource_group
  size                = var.vyos_vm_size
  tags                = var.tags

  network_interface_ids = [
    azurerm_network_interface.vyos_02_pub_nic.id,
    azurerm_network_interface.vyos_02_priv_nic.id
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.public_key)
  }

  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false


  custom_data = base64encode(templatefile("${path.module}/files/vyos_02_user_data.tpl", {
    vyos_02_priv_subnet   = var.transit_vnet_private_subnet_02_prefix[0],
    vyos_02_pub_nic_ip    = azurerm_network_interface.vyos_02_pub_nic.private_ip_address,
    vyos_02_priv_nic_ip   = azurerm_network_interface.vyos_02_priv_nic.private_ip_address,
    route_server_ip_01    = local.route_server_ips[0],
    route_server_ip_02    = local.route_server_ips[1],
    vyos_02_bgp_as_number = var.vyos_bgp_as_number,
    dns                   = var.dns,
    on_prem_pub_ip        = var.on_prem_pub_ip,
    on_prem_bgp_as_number = var.on_prem_bgp_as_number,
    data_vnet_subnet      = var.data_vnet_public_subnet_prefix[0]
  }))

  os_disk {
    name                 = "vyos-02-vm-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }


  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  plan {
    name      = var.image_sku
    publisher = var.image_publisher
    product   = var.image_offer
  }

  depends_on = [
    azurerm_network_interface.vyos_02_pub_nic,
    azurerm_network_interface.vyos_02_priv_nic,
    azurerm_public_ip.vyos_02_vm_public_ip
  ]

  timeouts {
    create = "60m"
    update = "30m"
    delete = "30m"
  }
}


# Ubuntu virtual machine parameters
resource "azurerm_linux_virtual_machine" "ubuntu_vm" {
  name                = "Ubuntu-VM"
  location            = var.location
  resource_group_name = var.resource_group
  size                = var.ubuntu_vm_size
  tags                = var.tags

  network_interface_ids = [
    azurerm_network_interface.ubuntu_vm_pub_nic.id
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.public_key)
  }

  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false

  os_disk {
    name                 = "Ubuntu-VM-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # Image reference for Ubuntu
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  # Dependencies to ensure network interfaces are created before the VM
  depends_on = [
    azurerm_subnet.data_vnet_public_subnet,
    azurerm_network_interface.ubuntu_vm_pub_nic
  ]

  timeouts {
    create = "60m"
    delete = "30m"
  }
}
