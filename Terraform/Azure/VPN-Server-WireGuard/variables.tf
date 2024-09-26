# General Variables

variable "location" {
  description = "The region where all resources will deploy"
  default     = "LOCATION EXAMPLE: West Europe"
}

variable "resource_group" {
  description = "The name of your Azure Resource Group."
  default     = "<YOUR RESOURCE GROUP>"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default = {
    environment = "Test"
    project     = "VyOS VPN Server"
    owner       = "VyOS Networks"
    created-by  = "Terraform"
  }
}

variable "prefix" {
  default = "WG-Server"
}

variable "dns_1" {
  default = "8.8.8.8"
}

variable "dns_2" {
  default = "8.8.4.4"
}

#------------------------------------------------------------------------------------------
# VyOS credentials

variable "admin_username" {
  description = "Administrator user name"
  default     = "vyos"
}

variable "admin_password" {
  description = "Administrator password"
  default     = "<ADMIN PASSWORD>"
}

#------------------------------------------------------------------------------------------
# Variables related VyOS VM and image selection

variable "vm_size" {
  description = "Specifies the size of the virtual machine."
  default     = "Standard_B2s"
}

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

#------------------------------------------------------------------------------------------
# Variables related Virtual Networks

variable "vnet_name" {
  description = "The name for your virtual network."
  default     = "Net-01"
}

variable "vnet_address_prefix" {
  description = "The address space that is used by the virtual network."
  default     = "10.1.0.0/16"
}

variable "vnet_pub_subnet_prefix" {
  description = "The address prefix to use for the subnet."
  default     = "10.1.1.0/24"
}

#------------------------------------------------------------------------------------------
# Variables related Wireguard Server

variable "wg_server_subnet_prefix" {
  description = "The address prefix to use for the subnet."
  default     = "10.1.2.0/24"
}

variable "wg_server_Private_IP" {
  description = "Wire Guard Server Address"
  default     = "10.1.2.1"
}

variable "wg_server_port" {
  description = "Wire Guard Server Port"
  default     = "51820"
}

variable "wg_client_IP" {
  description = "Wire Guard Client Address"
  default     = "10.1.2.11"
}

variable "wg_server_PrivKey" {
  description = "Generated private key for VPN server"
  default     = "MGRrol9mdevug6S5ksagHYXBHs0tsrLG4mCPCLLlqVY="
}

variable "wg_server_PublicKey" {
  description = "Generated public key for VPN server"
  default     = "0joKaK46kKLDmeBWXWnxLf8xP64UUniTl1nfPnRsvCY="
}

variable "wg_client_PrivKey" {
  description = "Generated private key for VPN client"
  default     = "KF8jW6cdE7nPjM2eVHEx/PnZV0duSAsKAslZEiqLv1s="
}

variable "wg_client_PublicKey" {
  description = "Generated public key for VPN client"
  default     = "OH9NFyoUaa1hK5ko72zy+rF7yPGycqd9fqcQ0+pLiWk="
}

variable "wg_client_PresharedKey" {
  description = "Generated preshared key for VPN client"
  default     = "eXdHmjDsb46xuqvqBDL+O+03Si2eauJkPt9XuhapWuE="
}