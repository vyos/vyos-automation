variable "resource_group" {
  description = "The name of the Resource Group"
  type        = string
  default     = "<AZURE_RESOURCE_GROUP>"
}

variable "location" {
  description = "Azure location for resources"
  type        = string
  default     = "West Europe"
}

variable "vnet_name" {
  description = "The name of the virtual network"
  type        = string
  default     = "vyos_test_net"
}

variable "public_subnet_name" {
  description = "The name of the public subnet"
  type        = string
  default     = "vyos_test_net_pub"
}

variable "private_subnet_name" {
  description = "The base name of the private subnets"
  type        = string
  default     = "vyos_test_net_priv"
}

variable "vnet_prefix" {
  description = "The virtual network prefix"
  type        = list(string)
  default     = ["192.168.0.0/16"]
}

variable "public_subnet_prefix" {
  description = "The public subnet prefix"
  type        = list(string)
  default     = ["192.168.1.0/24"]
}

variable "private_subnet_prefix" {
  description = "The private subnet prefix"
  type        = list(string)
  default     = ["192.168.11.0/24"]
}

variable "vyos_priv_nic_ip_address" {
  description = "VyOS VM Private NIC address"
  type        = string
  default     = "192.168.11.11"
}

variable "vyos_public_ip_address" {
  description = "VyOS VM Public address"
  type        = string
  default     = "192.168.1.11"
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
  default     = "P@ssw0rd1234"
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
    project     = "vyos-test"
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


# AWS Parameters

variable "aws_bgp_as_number" {
  default = "65001"
}

variable "aws_public_ip" {
  default = "192.0.2.1"
}

variable "aws_subnet_cidr" {
  default = "172.16.0.0/16"
}
