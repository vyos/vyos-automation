variable "image" {
  type    = string
  default = "projects/sentrium-public/global/images/vyos-1-3-5-20231222143039"
}

variable "project_id" {
  type = string
}

variable "zone" {
  type = string
}

##############################################################################
# You can choose more chipper type than n2-highcpu-4
##############################################################################

variable "machine_type" {
  type    = string
  default = "n2-highcpu-4"
}

variable "networks" {
  description = "The network name to attach the VM instance."
  type        = list(string)
  default     = ["default"]
}

variable "sub_networks" {
  description = "The sub network name to attach the VM instance."
  type        = list(string)
  default     = ["default"]
}

variable "external_ips" {
  description = "The external IPs assigned to the VM for public access."
  type        = list(string)
  default     = ["EPHEMERAL"]
}

variable "enable_tcp_22" {
  description = "Allow SSH traffic from the Internet"
  type        = bool
  default     = true
}

variable "enable_udp_500_4500" {
  description = "Allow IKE/IPSec traffic from the Internet"
  type        = bool
  default     = true
}

variable "vyos_user_data" {
  type    = string
  default = ""
}

// Marketplace requires this variable name to be declared
variable "goog_cm_deployment_name" {
  description = "VyOS Universal Router Deployment"
  type        = string
  default     = "vyos"
}

# GCP authentication file
variable "gcp_auth_file" {
  type        = string
  description = "GCP authentication file"
}

variable "password" {
   description = "pass for Ansible"
   type = string
   sensitive = true
}
variable "host"{
  description = "The IP of my Ansible"
  type = string
}
