provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_server
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "datacenter" {
  name = var.datacenter
}

data "vsphere_datastore" "datastore" {
  name          = var.datastore
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.cluster
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_resource_pool" "default" {
  name          = format("%s%s", data.vsphere_compute_cluster.cluster.name, "/Resources/terraform")
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_host" "host" {
  name          = var.host
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "network" {
  name          = var.network_name
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

## Deployment of VM from Remote OVF
resource "vsphere_virtual_machine" "vmFromRemoteOvf" {
  name                 = var.remotename
  datacenter_id        = data.vsphere_datacenter.datacenter.id
  datastore_id         = data.vsphere_datastore.datastore.id
  host_system_id       = data.vsphere_host.host.id
  resource_pool_id     = data.vsphere_resource_pool.default.id
  network_interface {
    network_id = data.vsphere_network.network.id
  }
  wait_for_guest_net_timeout = 2
  wait_for_guest_ip_timeout  = 2

  ovf_deploy {
    allow_unverified_ssl_cert = true
    remote_ovf_url            = var.url_ova
    disk_provisioning         = "thin"
    ip_protocol               = "IPv4"
    ip_allocation_policy = "dhcpPolicy"
    ovf_network_map = {
      "Network 1" = data.vsphere_network.network.id
      "Network 2" = data.vsphere_network.network.id
    }
  }
  vapp {
    properties = {
       "password"          = "12345678",
       "local-hostname"    = "terraform_vyos"
    }
  }
}

output "ip" {
  description = "default ip address of the deployed VM"
  value       = vsphere_virtual_machine.vmFromRemoteOvf.default_ip_address
}

# IP of AZ instance copied to a file ip.txt in local system

resource "local_file" "ip" {
    content  = vsphere_virtual_machine.vmFromRemoteOvf.default_ip_address
    filename = "ip.txt"
}

#Connecting to the Ansible control node using SSH connection

resource "null_resource" "nullremote1" {
depends_on = ["vsphere_virtual_machine.vmFromRemoteOvf"]
connection {
 type     = "ssh"
 user     = "root"
 password = var.ansiblepassword
 host = var.ansiblehost

}

# Copying the ip.txt file to the Ansible control node from local system

 provisioner "file" {
    source      = "ip.txt"
    destination = "/root/vsphere/ip.txt"
       }
}

resource "null_resource" "nullremote2" {
depends_on = ["vsphere_virtual_machine.vmFromRemoteOvf"]
connection {
        type     = "ssh"
        user     = "root"
        password = var.ansiblepassword
        host = var.ansiblehost
}

# Command to run ansible playbook on remote Linux OS

provisioner "remote-exec" {

    inline = [
        "cd /root/vsphere/",
        "ansible-playbook instance.yml"
]
}
}