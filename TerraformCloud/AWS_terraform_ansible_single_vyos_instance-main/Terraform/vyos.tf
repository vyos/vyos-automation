terraform {
 required_providers {
   aws = {
     source  = "hashicorp/aws"
     version = "~> 5.0"
   }
 }
}

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
 default = "ami-**************"                        # ami image please enter your details  
 description = "Amazon Machine Image ID for VyOS"
}

variable "type" {
 default = "t2.micro"
 description = "Size of VM"
}

# my resource for VyOS

resource "aws_instance" "myVyOSec2" {
 ami = var.ami
 key_name = "mykeyname"                                # Please enter your details  
 security_groups = ["my_sg"]                           # Please enter your details  
 instance_type = var.type
 tags = {
   name = "VyOS System"
 }
}

output "my_IP"{
value = aws_instance.myVyOSec2.public_ip
}


#IP of aws instance copied to a file ip.txt in local system Terraform

resource "local_file" "ip" {
    content  = aws_instance.myVyOSec2.public_ip
    filename = "ip.txt"
}

#connecting to the Ansible control node using SSH connection

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
	"ansible-playbook instance.yml"
]
}
}
