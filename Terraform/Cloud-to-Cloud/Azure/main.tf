
# Public IP for VyOS VM
resource "azurerm_public_ip" "vyos_vm_public_ip" {
  name                    = "vyov-vm-public-ip"
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

# Public IP for Ubuntu VM
resource "azurerm_public_ip" "ubuntu_vm_public_ip" {
  name                    = "Ubuntu-VM-Public-IP"
  location                = var.location
  resource_group_name     = var.resource_group
  allocation_method       = "Static"
  sku                     = "Standard"
  tags                    = var.tags
  idle_timeout_in_minutes = "30"

}

# VyOS Public NIC
resource "azurerm_network_interface" "vyos_pub_nic" {
  name                = "vyos-pub-nic"
  location            = var.location
  resource_group_name = var.resource_group
  tags                = var.tags

  ip_configuration {
    name                          = "vyos-public"
    subnet_id                     = azurerm_subnet.test_vnet_public.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.vyos_public_ip_address
    public_ip_address_id          = azurerm_public_ip.vyos_vm_public_ip.id
  }

  timeouts {
    create = "10m"
    delete = "10m"
  }
}

# VyOS Private NIC
resource "azurerm_network_interface" "vyos_priv_nic" {
  name                = "vyos-priv-nic"
  location            = var.location
  resource_group_name = var.resource_group
  tags                = var.tags

  ip_forwarding_enabled          = true
  accelerated_networking_enabled = true

  ip_configuration {
    name                          = "vyos-private"
    subnet_id                     = azurerm_subnet.test_vnet_private.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.vyos_priv_nic_ip_address
  }

  timeouts {
    create = "10m"
    delete = "10m"
  }
}

# NIC for Ubuntu VM

resource "azurerm_network_interface" "ubuntu_vm_nic" {
  name                = "ubuntu-vm-nic"
  location            = var.location
  resource_group_name = var.resource_group
  tags                = var.tags

  ip_configuration {
    name                          = "ubuntu"
    subnet_id                     = azurerm_subnet.test_vnet_private.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ubuntu_vm_public_ip.id
  }

}

# VyOS virtual machine parameters
resource "azurerm_linux_virtual_machine" "vyos_vm" {
  name                = "vyos-vm"
  location            = var.location
  resource_group_name = var.resource_group
  size                = var.vyos_vm_size
  tags                = var.tags

  network_interface_ids = [
    azurerm_network_interface.vyos_pub_nic.id,
    azurerm_network_interface.vyos_priv_nic.id
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.public_key)
  }

  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false

  custom_data = base64encode(templatefile("${path.module}/files/vyos_user_data.tpl", {
    private_subnet_cidr       = join("", var.private_subnet_prefix),
    vyos_public_ip_address    = azurerm_public_ip.vyos_vm_public_ip.ip_address,
    vyos_pub_nic_ip           = azurerm_network_interface.vyos_pub_nic.private_ip_address,
    vyos_priv_nic_ip          = azurerm_network_interface.vyos_priv_nic.private_ip_address,
    vyos_bgp_as_number        = var.vyos_bgp_as_number,
    dns                       = var.dns,
    aws_public_ip             = var.aws_public_ip,
    aws_bgp_as_number         = var.aws_bgp_as_number
  }))

  os_disk {
    name                 = "vyos-vm-osdisk"
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
    azurerm_network_interface.vyos_pub_nic,
    azurerm_network_interface.vyos_priv_nic,
    azurerm_public_ip.vyos_vm_public_ip
  ]

  timeouts {
    create = "60m"
    update = "30m"
    delete = "30m"
  }
}

# Ubuntu virtual machine parameters
resource "azurerm_linux_virtual_machine" "ubuntu_vm" {
  name                         = "Ubuntu-VM"
  location                     = var.location
  resource_group_name          = var.resource_group
  size                         = var.ubuntu_vm_size
  tags                         = var.tags

  network_interface_ids = [
    azurerm_network_interface.ubuntu_vm_nic.id
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
    azurerm_subnet.test_vnet_private,
    azurerm_network_interface.ubuntu_vm_nic
  ]

  timeouts {
    create = "60m"
    delete = "30m"
  }
}
