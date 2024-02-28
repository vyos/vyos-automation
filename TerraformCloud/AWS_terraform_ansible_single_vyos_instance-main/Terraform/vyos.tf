##############################################################################
# Build an VyOS VM from the Marketplace
# To finde nessesery AMI image_ in AWS
#
# In the script vyos.tf we'll use default values (you can chang it as you need)
# AWS Region = "us-east-1"
# AMI        = "standard AMI of VyOS from AWS Marketplace"
# Size of VM = "t2.micro"
# AWS Region = "us-east-1"
# After deploying the AWS instance and getting an IP address, the IP address is copied into the file  
#"ip.txt" and copied to the Ansible node for provisioning.
##############################################################################

provider "aws" {
 access_key = var.access 
 secret_key = var.secret 
 region = var.region
}

variable "region" {
 default = "us-east-1"
 description = "AWS Region"
}

variable "ami" {
 default = "ami-**************3b3"                        # ami image please enter your details  
 description = "Amazon Machine Image ID for VyOS"
}

variable "type" {
 default = "t2.micro"
 description = "Size of VM"
}

# my resource for VyOS

resource "aws_instance" "myVyOSec2" {
 ami = var.ami
 key_name = "awsterraform"                                      # Please enter your details from 1.2 of Preparation steps for deploying VyOS on AWS 
 security_groups = ["awsterraformsg"]                           # Please enter your details from 1.3 of Preparation steps for deploying VyOS on AWS 
 instance_type = var.type
 tags = {
   name = "VyOS System"
 }
}

##############################################################################
# specific variable (to getting type "terraform plan"):
# aws_instance.myVyOSec2.public_ip - the information about public IP address
# of our instance, needs for provisioning and ssh connection from Ansible
##############################################################################

output "my_IP"{
value = aws_instance.myVyOSec2.public_ip
}

##############################################################################
# 
# IP of aws instance copied to a file ip.txt in local system Terraform
# ip.txt looks like: 
# cat ./ip.txt
# ххх.ххх.ххх.ххх
##############################################################################

resource "local_file" "ip" {
    content  = aws_instance.myVyOSec2.public_ip
    filename = "ip.txt"
}

#connecting to the Ansible control node using SSH connection

##############################################################################
# Steps "SSHconnection1" and "SSHconnection2" need to get file ip.txt from the terraform node and start remotely the playbook of Ansible.
##############################################################################

resource "null_resource" "SSHconnection1" {
depends_on = [aws_instance.myVyOSec2] 
connection {
 type     = "ssh"
 user     = "root"
 password = var.password
     host = var.host
}

#copying the ip.txt file to the Ansible control node from local system 

 provisioner "file" {
    source      = "ip.txt"
    destination = "/root/aws/ip.txt"                             # The folder of your Ansible project
       }
}

resource "null_resource" "SSHconnection2" {
depends_on = [aws_instance.myVyOSec2]  
connection {
    type     = "ssh"
    user     = "root"
    password = var.password
        host = var.host
}
#command to run Ansible playbook on remote Linux OS
provisioner "remote-exec" {
    inline = [
      "cd /root/aws/",
      "ansible-playbook instance.yml"                               # more detailed in "File contents of Ansible for AWS"
]
}
}