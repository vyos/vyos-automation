# General Variables

variable "location" {
  description = "The region where all resources will deploy"
  default     = "West Europe"
}

variable "resource_group" {
  description = "The name of your Azure Resource Group."
  default     = "aslan_resource_group"
}

variable "vm_size" {
  description = "Specifies the size of the virtual machine."
  default     = "Standard_B2s"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default = {
    environment = "Test"
    project     = "VyOS sample VPN"
    owner       = "VyOS Company"
    created-by  = "Terraform"
  }
}

variable "prefix" {
  default = "VPN-Instance"
}

variable "dns_1" {
  default = "8.8.8.8"
}

variable "dns_2" {
  default = "8.8.4.4"
}

# -----------------------------------------------------------------
# Variables related credentials
variable "admin_username" {
  description = "Administrator user name"
  default     = "vyos"
}

variable "admin_password" {
  description = "Administrator password"
  default     = "User1234!"
}

# -----------------------------------------------------------------
# Variables related image selection

variable "image_publisher" {
  description = "Name of the publisher of the image (az vm image list)"
  default     = "sentriumsl"
}

variable "image_offer" {
  description = "Name of the offer (az vm image list)"
  default     = "vyos-1-2-lts-on-azure"
}

variable "image_sku" {
  description = "Image SKU to apply (az vm image list)"
  default     = "vyos-1-3"
}

variable "image_version" {
  description = "Version of the image to apply (az vm image list)"
  default     = "1.4.0"
}

# -----------------------------------------------------
# Variables related Virtual Networks

# VNet 01

variable "vnet_01_name" {
  description = "The name for your virtual network."
  default     = "Net-01"
}

variable "vnet_01_address_prefix" {
  description = "The address space that is used by the virtual network."
  default     = "10.1.0.0/16"
}

variable "vnet_01_priv_subnet_prefix" {
  description = "The address prefix to use for the subnet."
  default     = "10.1.1.0/24"
}

variable "vnet_01_pub_subnet_prefix" {
  description = "The address prefix to use for the subnet."
  default     = "10.1.11.0/24"
}

variable "vnet_01_bgp_as_number" {
  default = "65001"
}

# On Prem Data Center

variable "on_prem_bgp_as_number" {
  default = "65002"
}

variable "on_prem_public_ip_address" {
  default = "192.0.2.1"
}
