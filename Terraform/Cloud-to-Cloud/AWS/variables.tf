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

variable "vyos_ami_id" {
  description = "VyOS custom AMI from AWS"
  type        = string
  default     = "<VYOS-AMI-ID>"
}

variable "prefix" {
  type        = string
  description = "Prefix for the resource names and Name tags"
  default     = "lab"
}

variable "key_pair_name" {
  description = "SSH key pair name"
  type        = string
  default     = "vyos-test-key"
}

variable "private_key_path" {
  description = "Path to the private key file"
  default     = "keys/vyos_lab_private_key.pem"
}

variable "public_key_path" {
  description = "Path to the private key file"
  default     = "keys/vyos_lab_public_key.pem"
}

# Transit VPC and Subnets

variable "transit_vpc_name" {
  description = "Name for VPC"
  default     = "transit-vpc"
}

variable "transit_vpc_public_subnet_name" {
  description = "The name of the public subnet"
  type        = string
  default     = "pub-subnet"
}

variable "transit_vpc_private_subnet_name" {
  description = "The name of the private subnet"
  type        = string
  default     = "priv-subnet"
}

variable "transit_vpc_cidr" {
  description = "CIDR block for VPC"
  default     = "172.16.0.0/16"
}

variable "transit_vpc_public_subnet_cidr" {
  description = "CIDR block for public subnet"
  default     = "172.16.1.0/24"
}

variable "transit_vpc_private_subnet_cidr" {
  description = "CIDR block for private subnet"
  default     = "172.16.11.0/24"
}

variable "transit_vpc_igw_name" {
  type    = string
  default = "transit-vpc-igw"
}

variable "vyos_eip_name" {
  type    = string
  default = "vyos"
}

variable "transit_vpc_public_rtb_name" {
  type    = string
  default = "transit-vpc-public-rtb"
}

variable "transit_vpc_private_rtb_name" {
  type    = string
  default = "transit-vpc-private-rtb"
}

variable "transit_vpc_public_sg_name" {
  type    = string
  default = "transit-vpc-public-sg"
}

variable "transit_vpc_private_sg_name" {
  type    = string
  default = "transit-vpc-private-sg"
}

# VyOS instance

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

variable "dns" {
  default = "8.8.8.8"
}

variable "vyos_bgp_as_number" {
  default = "65001"
}

# Azure variables

variable "azure_bgp_as_number" {
  default = "65002"
}

variable "azure_public_ip_address" {
  default = "192.0.2.2"
}

variable "azure_subnet_cidr" {
  default = "192.168.0.0/16"
}
