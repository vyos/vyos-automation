variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "availability_zone" {
  description = "AWS Availability Zone"
  type        = string
  default     = "us-east-1a"
}

variable "prefix" {
  type        = string
  description = "Prefix for the resource names and Name tags"
  default     = "demo"
}

variable "key_pair_name" {
  description = "SSH key pair name"
  type        = string
  default     = "vyos-demo-key"
}

variable "private_key_path" {
  description = "Path to the private key file"
  default     = "keys/vyos_demo_private_key.pem"
}

variable "public_key_path" {
  description = "Path to the private key file"
  default     = "keys/vyos_demo_public_key.pem"
}

variable "vpc_name" {
  description = "Name for VPC"
  default     = "test-vpc"
}

variable "public_subnet_name" {
  description = "The name of the public subnet"
  type        = string
  default     = "pub-subnet"
}

variable "private_subnet_name" {
  description = "The name of the private subnet 01"
  type        = string
  default     = "priv-subnet"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "172.16.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  default     = "172.16.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for private subnet"
  type        = string
  default     = "172.16.11.0/24"
}

variable "vyos_pub_nic_ip_address" {
  description = "VyOS Instance Public address"
  type        = string
  default     = "172.16.1.11"
}

variable "vyos_priv_nic_address" {
  description = "VyOS Instance Private NIC address"
  type        = string
  default     = "172.16.11.11"
}

variable "vyos_instance_type" {
  description = "The type of the VyOS Instance"
  type        = string
  default     = "c5n.xlarge"
}

variable "vyos_instance_name" {
  type    = string
  default = "VyOS"
}

variable "igw_name" {
  type    = string
  default = "igw"
}

variable "vyos_eip_name" {
  type    = string
  default = "vyos"
}

variable "public_rtb_name" {
  type    = string
  default = "public-rtb"

}

variable "public_sg_name" {
  type    = string
  default = "public-sg"
}

variable "private_sg_name" {
  type    = string
  default = "private-sg"
}

variable "dns" {
  default = "8.8.8.8"
}

variable "vyos_bgp_as_number" {
  default = "65001"
}

# On Prem Data Center

variable "on_prem_bgp_as_number" {
  default = "65002"
}

variable "on_prem_public_ip_address" {
  default = "192.0.2.1"
}
