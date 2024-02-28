# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "vsphere_server" {
  description = "vSphere server"
  type        = string
}

variable "vsphere_user" {
  description = "vSphere username"
  type        = string
}

variable "vsphere_password" {
  description = "vSphere password"
  type        = string
  sensitive   = true
}

variable "datacenter" {
  description = "vSphere data center"
  type        = string
}

variable "cluster" {
  description = "vSphere cluster"
  type        = string
}

variable "datastore" {
  description = "vSphere datastore"
  type        = string
}

variable "network_name" {
  description = "vSphere network name"
  type        = string
}

variable "host" {
  description = "name if yor host"
  type        = string
}

variable "remotename" {
  description = "the name of you VM"
  type        = string
}

variable "url_ova" {
  description = "the URL to .OVA file or cloude store"
  type        = string
}

variable "ansiblepassword" {
  description = "Ansible password"
  type        = string
}

variable "ansiblehost" {
  description = "Ansible host name or IP"
  type        = string
}