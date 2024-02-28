##############################################################################
# HashiCorp Guide to Using Terraform on Azure
# This Terraform configuration will create the following:
## Resource group with a virtual network and subnet
# An VyOS server without ssh key (only login+password)
##############################################################################

# Chouse a provider

provider "azurerm" {
  features {}
}

# Create a resource group. In Azure every resource belongs to a 
# resource group. 

resource "azurerm_resource_group" "azure_vyos" {
  name     = "${var.resource_group}"
  location = "${var.location}"
}

# The next resource is a Virtual Network.

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.virtual_network_name}"
  location            = "${var.location}"
  address_space       = ["${var.address_space}"]
  resource_group_name = "${var.resource_group}"
}

# Build a subnet to run our VMs in.

resource "azurerm_subnet" "subnet" {
  name                 = "${var.prefix}subnet"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  resource_group_name = "${var.resource_group}"
  address_prefixes       = ["${var.subnet_prefix}"]
}

##############################################################################
# Build an VyOS VM from the Marketplace
# To finde nessesery image use the command:
#
# az vm image list --offer vyos --all
#
# Now that we have a network, we'll deploy an VyOS server.
# An Azure Virtual Machine has several components. In this example we'll build
# a security group, a network interface, a public ip address, a storage 
# account and finally the VM itself. Terraform handles all the dependencies 
# automatically, and each resource is named with user-defined variables.
##############################################################################


# Security group to allow inbound access on port 22 (ssh)

resource "azurerm_network_security_group" "vyos-sg" {
  name                = "${var.prefix}-sg"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group}"

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "${var.source_network}"
    destination_address_prefix = "*"
  }
}

# A network interface.

resource "azurerm_network_interface" "vyos-nic" {
  name                      = "${var.prefix}vyos-nic"
  location                  = "${var.location}"
  resource_group_name       = "${var.resource_group}"

  ip_configuration {
    name                          = "${var.prefix}ipconfig"
    subnet_id                     = "${azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.vyos-pip.id}"
  }
}

# Add a public IP address.

resource "azurerm_public_ip" "vyos-pip" {
  name                         = "${var.prefix}-ip"
  location                     = "${var.location}"
  resource_group_name          = "${var.resource_group}"
  allocation_method            = "Dynamic"
}

# Build a virtual machine. This is a standard VyOS instance from Marketplace.

resource "azurerm_virtual_machine" "vyos" {
  name                = "${var.hostname}-vyos"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group}" 
  vm_size             = "${var.vm_size}"

  network_interface_ids         = ["${azurerm_network_interface.vyos-nic.id}"]
  delete_os_disk_on_termination = "true"

# To finde an information about the plan use the command:
# az vm image list --offer vyos --all

  plan {
    publisher = "sentriumsl"
    name      = "vyos-1-3"
    product   = "vyos-1-2-lts-on-azure"
  }

  storage_image_reference {
    publisher = "${var.image_publisher}"
    offer     = "${var.image_offer}"
    sku       = "${var.image_sku}"
    version   = "${var.image_version}"
  }

  storage_os_disk {
    name              = "${var.hostname}-osdisk"
    managed_disk_type = "Standard_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

  os_profile {
    computer_name  = "${var.hostname}"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

data "azurerm_public_ip" "example" {
  depends_on = ["azurerm_virtual_machine.vyos"]
  name                = "vyos-ip"
  resource_group_name = "${var.resource_group}"
}
output "public_ip_address" {
  value = data.azurerm_public_ip.example.ip_address
}

# IP of AZ instance copied to a file ip.txt in local system

resource "local_file" "ip" {
    content  = data.azurerm_public_ip.example.ip_address
    filename = "ip.txt"
}

#Connecting to the Ansible control node using SSH connection

resource "null_resource" "nullremote1" {
depends_on = ["azurerm_virtual_machine.vyos"] 
connection {
 type     = "ssh"
 user     = "root"
 password = var.password
     host = var.host
}

# Copying the ip.txt file to the Ansible control node from local system 

 provisioner "file" {
    source      = "ip.txt"
    destination = "/root/az/ip.txt"
       }
}

resource "null_resource" "nullremote2" {
depends_on = ["azurerm_virtual_machine.vyos"]  
connection {
	type     = "ssh"
	user     = "root"
	password = var.password
    	host = var.host
}

# Command to run ansible playbook on remote Linux OS

provisioner "remote-exec" {
    
    inline = [
	"cd /root/az/",
	"ansible-playbook instance.yml"
]
}
}