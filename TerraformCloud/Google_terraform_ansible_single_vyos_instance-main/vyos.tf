##############################################################################
# Build an VyOS VM from the Marketplace
#
# After deploying the GCP instance and getting an IP address, the IP address is copied into the file
#"ip.txt" and copied to the Ansible node for provisioning.
##############################################################################

terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}

provider "google" {
  project         = var.project_id
  request_timeout = "60s"
  credentials = file(var.gcp_auth_file)
}

locals {
  network_interfaces = [for i, n in var.networks : {
    network     = n,
    subnetwork  = length(var.sub_networks) > i ? element(var.sub_networks, i) : null
    external_ip = length(var.external_ips) > i ? element(var.external_ips, i) : "NONE"
    }
  ]
}

resource "google_compute_instance" "default" {
  name         = var.goog_cm_deployment_name
  machine_type = var.machine_type
  zone         = var.zone

  metadata = {
    enable-oslogin     = "FALSE"
    serial-port-enable = "TRUE"
    user-data          = var.vyos_user_data
  }
  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  can_ip_forward = true

  dynamic "network_interface" {
    for_each = local.network_interfaces
    content {
      network    = network_interface.value.network
      subnetwork = network_interface.value.subnetwork
      nic_type   = "GVNIC"
      dynamic "access_config" {
        for_each = network_interface.value.external_ip == "NONE" ? [] : [1]
        content {
          nat_ip = network_interface.value.external_ip == "EPHEMERAL" ? null : network_interface.value.external_ip
        }
      }
    }
  }
}

resource "google_compute_firewall" "tcp_22" {
  count = var.enable_tcp_22 ? 1 : 0

  name    = "${var.goog_cm_deployment_name}-tcp-22"
  network = element(var.networks, 0)

  allow {
    ports    = ["22"]
    protocol = "tcp"
  }

  source_ranges = ["0.0.0.0/0"]

  target_tags = ["${var.goog_cm_deployment_name}-deployment"]
}

resource "google_compute_firewall" "udp_500_4500" {
  count = var.enable_udp_500_4500 ? 1 : 0

  name    = "${var.goog_cm_deployment_name}-udp-500-4500"
  network = element(var.networks, 0)

allow {
  ports    = ["500", "4500"]
  protocol = "udp"
}

source_ranges = ["0.0.0.0/0"]

  target_tags = ["${var.goog_cm_deployment_name}-deployment"]
}

output "public_ip_address" {
  value = google_compute_instance.default.network_interface[0].access_config[0].nat_ip
}

##############################################################################
#
# IP of google instance copied to a file ip.txt in local system Terraform
# ip.txt looks like:
# cat ./ip.txt
# ххх.ххх.ххх.ххх
##############################################################################

resource "local_file" "ip" {
    content  = google_compute_instance.default.network_interface[0].access_config[0].nat_ip
    filename = "ip.txt"
}

#connecting to the Ansible control node using SSH connection

##############################################################################
# Steps "SSHconnection1" and "SSHconnection2" need to get file ip.txt from the terraform node and start remotely the playbook of Ansible.
##############################################################################

resource "null_resource" "SSHconnection1" {
depends_on = ["google_compute_instance.default"]
connection {
   type     = "ssh"
   user     = "root"
   password = var.password
   host     = var.host
}

#copying the ip.txt file to the Ansible control node from local system

 provisioner "file" {
    source      = "ip.txt"
    destination = "/root/google/ip.txt"                             # The folder of your Ansible project
       }
}

resource "null_resource" "SSHconnection2" {
depends_on = ["google_compute_instance.default"]
connection {
    type     = "ssh"
    user     = "root"
        password = var.password
    host     = var.host
}

#command to run Ansible playbook on remote Linux OS

provisioner "remote-exec" {
    inline = [
    "cd /root/google/",
    "ansible-playbook instance.yml"                               # more detailed in "File contents of Ansible for google cloud"
]
}
}
