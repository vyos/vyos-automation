# EC2 KEY PAIR

resource "aws_key_pair" "ec2_key" {
  key_name   = "${var.prefix}-${var.key_pair_name}"
  public_key = file(var.public_key_path)

  tags = {
    Name = "${var.prefix}-${var.key_pair_name}"
  }
}

# THE LATEST AMAZON VYOS 1.4 IMAGE
#
# VyOS AWS Marketplace publisher account ID: 679593333241
# This ID is required for filtering official VyOS AMIs via `aws ec2 describe-images`.
# The value corresponds to the AMI owner ID used by VyOS in the AWS Marketplace.
#
# To confirm or update the AMI and owner ID, you must first subscribe to VyOS in the AWS Marketplace.
# Then run the following command to fetch the correct AMI ID and Owner ID for your AWS region (e.g., us-east-1):
#
# aws ec2 describe-images --owners aws-marketplace --filters "Name=product-code,Values=8wqdkv3u2b9sa0y73xob2yl90" --query 'Images[*].[ImageId,OwnerId,Name]' --output table

data "aws_ami" "vyos" {
  most_recent = true

  filter {
    name   = "name"
    values = ["VyOS 1.4*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["679593333241"]
}

# Latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# VYOS INSTANCE

resource "aws_instance" "vyos" {
  ami               = data.aws_ami.vyos.id
  #ami               = var.vyos_ami_id
  instance_type     = var.vyos_instance_type
  key_name          = "${var.prefix}-${var.key_pair_name}"
  availability_zone = var.availability_zone

  user_data_base64 = base64encode(templatefile("${path.module}/files/vyos_user_data.tfpl", {
    transit_vpc_cidr      = var.transit_vpc_cidr,
    vyos_public_ip     = aws_eip.vyos_eip.public_ip,
    vyos_pub_subnet    = var.transit_vpc_public_subnet_cidr,
    vyos_priv_subnet   = var.transit_vpc_private_subnet_cidr,
    vyos_pub_nic_ip    = aws_network_interface.vyos_public_nic.private_ip,
    vyos_priv_nic_ip   = aws_network_interface.vyos_private_nic.private_ip,
    vyos_bgp_as_number = var.vyos_bgp_as_number,
    dns                = var.dns,
    azure_public_ip    = var.azure_public_ip_address,
    azure_bgp_as_number = var.azure_bgp_as_number,
    azure_subnet_cidr   = var.azure_subnet_cidr,
  }))

  depends_on = [
    aws_network_interface.vyos_public_nic,
    aws_network_interface.vyos_private_nic
  ]

  network_interface {
    network_interface_id = aws_network_interface.vyos_public_nic.id
    device_index         = 0
  }

  network_interface {
    network_interface_id = aws_network_interface.vyos_private_nic.id
    device_index         = 1
  }

  tags = {
    Name = "${var.prefix}-${var.vyos_instance_name}"
  }
}

# NETWORK INTERFACES

resource "aws_network_interface" "vyos_public_nic" {
  subnet_id         = aws_subnet.transit_vpc_public_subnet.id
  security_groups   = [aws_security_group.public_sg.id]
  private_ips       = [var.vyos_pub_nic_ip_address]
  source_dest_check = false

  tags = {
    Name = "${var.prefix}-${var.vyos_instance_name}-PublicNIC"
  }
}

resource "aws_network_interface" "vyos_private_nic" {
  subnet_id         = aws_subnet.transit_vpc_private_subnet.id
  security_groups   = [aws_security_group.private_sg.id]
  private_ips       = [var.vyos_priv_nic_address]
  source_dest_check = false

  tags = {
    Name = "${var.prefix}-${var.vyos_instance_name}-PrivateNIC"
  }
}

# Amazon EC2 Instance
resource "aws_instance" "amazon_ec2_instance" {
  ami                         = data.aws_ami.amazon_linux.id
  availability_zone           = var.availability_zone
  instance_type               = "t3.micro"
  key_name                    = "${var.prefix}-${var.key_pair_name}"
  subnet_id                   = aws_subnet.transit_vpc_private_subnet.id
  vpc_security_group_ids      = [aws_security_group.public_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "${var.prefix}-Amazon-EC2-instance"
  }
}
