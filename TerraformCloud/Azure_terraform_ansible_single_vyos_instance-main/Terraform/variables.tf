##############################################################################
# Variables File
# 
# Here is where we store the default values for all the variables used in our
# Terraform code.
##############################################################################

variable "resource_group" {
  description = "The name of your Azure Resource Group."
  default     = "my_resource_group"
}

variable "prefix" {
  description = "This prefix will be included in the name of some resources."
  default     = "vyos"
}

variable "hostname" {
  description = "Virtual machine hostname. Used for local hostname, DNS, and storage-related names."
  default     = "vyos_terraform"
}

variable "location" {
  description = "The region where the virtual network is created."
  default     = "centralus"
}

variable "virtual_network_name" {
  description = "The name for your virtual network."
  default     = "vnet"
}

variable "address_space" {
  description = "The address space that is used by the virtual network. You can supply more than one address space. Changing this forces a new resource to be created."
  default     = "10.0.0.0/16"
}

variable "subnet_prefix" {
  description = "The address prefix to use for the subnet."
  default     = "10.0.10.0/24"
}

variable "storage_account_tier" {
  description = "Defines the storage tier. Valid options are Standard and Premium."
  default     = "Standard"
}

variable "storage_replication_type" {
  description = "Defines the replication type to use for this storage account. Valid options include LRS, GRS etc."
  default     = "LRS"
}

# The most chippers size

variable "vm_size" {
  description = "Specifies the size of the virtual machine."
  default     = "Standard_B1s"
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
  default     = "1.3.3"
}

variable "admin_username" {
  description = "Administrator user name"
  default     = "vyos"
}

variable "admin_password" {
  description = "Administrator password"
  default     = "Vyos0!"
}

variable "source_network" {
  description = "Allow access from this network prefix. Defaults to '*'."
  default     = "*"
}

variable "password" {
   description = "pass for Ansible"
   type = string
   sensitive = true
}
variable "host"{
   description = "IP of my Ansible"
}
