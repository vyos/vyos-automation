variable "resource_group" {
  description = "The name of the Resource Group"
  type        = string
}

variable "location" {
  description = "Azure location for resources"
  type        = string
  default     = "West Europe"
}

variable "transit_vnet_name" {
  description = "The name of the virtual network"
  type        = string
  default     = "vyos_transit_net"
}

variable "data_vnet_name" {
  description = "The name of the virtual network"
  type        = string
  default     = "vyos_data_net"
}

variable "transit_vnet_public_subnet_name" {
  description = "The name of the public subnet"
  type        = string
  default     = "vyos_transit_net_pub"
}

variable "transit_vnet_private_subnet_name" {
  description = "The base name of the private subnets"
  type        = string
  default     = "vyos_transit_net_priv"
}

variable "data_vnet_public_subnet_name" {
  description = "The name of the data vnet public subnet"
  type        = string
  default     = "data_net_pub"
}

variable "ssh_allowed_cidr" {
  description = "The CIDR block that is allowed to SSH into the VMs"
  type        = string
  default     = "0.0.0.0/0"
}

variable "subscription_id" {
  description = "The Azure subscription ID"
  type        = string
}

variable "transit_vnet_prefix" {
  description = "The virtual network prefix"
  type        = list(string)
  default     = ["192.168.0.0/19"]
}

variable "data_vnet_prefix" {
  description = "The virtual network prefix"
  type        = list(string)
  default     = ["192.168.32.0/19"]
}

variable "transit_vnet_public_subnet_01_prefix" {
  description = "The public subnet 01 prefix"
  type        = list(string)
  default     = ["192.168.1.0/24"]
}

variable "transit_vnet_private_subnet_01_prefix" {
  description = "The private subnet 01 prefix"
  type        = list(string)
  default     = ["192.168.11.0/24"]
}

variable "transit_vnet_public_subnet_02_prefix" {
  description = "The public subnet 02 prefix"
  type        = list(string)
  default     = ["192.168.2.0/24"]
}

variable "transit_vnet_private_subnet_02_prefix" {
  description = "The private subnet 02 prefix"
  type        = list(string)
  default     = ["192.168.21.0/24"]
}

variable "data_vnet_public_subnet_prefix" {
  description = "The data vnet public subnet prefix"
  type        = list(string)
  default     = ["192.168.41.0/24"]
}

variable "route_server_subnet_prefix" {
  description = "The data vnet public subnet prefix"
  type        = list(string)
  default     = ["192.168.3.0/27"]
}

variable "vyos_01_public_nic_ip_address" {
  description = "VyOS VM Public NIV 01 address"
  type        = string
  default     = "192.168.1.11"
}

variable "vyos_01_priv_nic_ip_address" {
  description = "VyOS VM Private NIC 01 address"
  type        = string
  default     = "192.168.11.11"
}

variable "vyos_02_public_nic_ip_address" {
  description = "VyOS VM Public NIV 02 address"
  type        = string
  default     = "192.168.2.11"
}

variable "vyos_02_priv_nic_ip_address" {
  description = "VyOS VM Private NIC 02 address"
  type        = string
  default     = "192.168.21.11"
}

variable "vyos_vm_size" {
  description = "The size of the VyOS VM"
  type        = string
  default     = "Standard_DS3_v2"
}

variable "admin_username" {
  description = "Admin username for the VMs"
  type        = string
  default     = "adminuser"
}

variable "admin_password" {
  description = "Admin password for the VMs"
  type        = string
  sensitive   = true
}

variable "public_key" {
  description = "Path to public key"
  type        = string
  default     = "keys/id_rsa.pub"
}

variable "private_key" {
  description = "Path to private key"
  type        = string
  default     = "keys/id_rsa"
}

variable "image_publisher" {
  description = "Name of the publisher of the image"
  type        = string
  default     = "sentriumsl"
}

variable "image_offer" {
  description = "Name of the offer"
  type        = string
  default     = "vyos-1-2-lts-on-azure"
}

variable "image_sku" {
  description = "Image SKU to apply"
  type        = string
  default     = "vyos-1-3"
}

variable "image_version" {
  description = "Version of the image to apply"
  type        = string
  default     = "latest"
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default = {
    environment = "lab"
    project     = "vyos-demo"
  }
}

variable "dns" {
  default = "8.8.8.8"
}

variable "vyos_bgp_as_number" {
  default = "65002"
}

# Ubuntu VM
variable "ubuntu_vm_size" {
  description = "The size of the Ubuntu VM"
  type        = string
  default     = "Standard_B2s"
}


# On Prem Data Center

variable "on_prem_bgp_as_number" {
  default = "65001"
}

variable "on_prem_pub_ip" {
  default = "192.0.2.1"
}
