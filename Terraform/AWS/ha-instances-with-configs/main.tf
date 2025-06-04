# EC2 KEY PAIR

resource "aws_key_pair" "ec2_key" {
  key_name   = "${var.prefix}-${var.key_pair_name}"
  public_key = file(var.public_key_path)

  tags = {
    Name = "${var.prefix}-${var.key_pair_name}"
  }
}

# THE LATEST AMAZON VYOS 1.4 IMAGE

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

resource "aws_instance" "vyos_01" {
  ami               = data.aws_ami.vyos.id
  # ami               = var.vyos_ami_id
  instance_type     = var.vyos_instance_type
  key_name          = "${var.prefix}-${var.key_pair_name}"
  availability_zone = var.availability_zone_01

  user_data_base64 = base64encode(templatefile("${path.module}/files/vyos_01_user_data.tfpl", {
    transit_vpc_cidr           = var.transit_vpc_cidr,
    data_vpc_public_subnet     = var.data_vpc_public_subnet_cidr,
    vyos_public_ip_address     = aws_eip.vyos_01_eip.public_ip,
    vyos_pub_subnet            = var.transit_vpc_public_subnet_01_cidr,
    vyos_priv_subnet           = var.transit_vpc_private_subnet_01_cidr,
    vyos_02_pub_nic_ip_address = aws_network_interface.vyos_02_public_nic.private_ip,
    vyos_pub_nic_ip            = aws_network_interface.vyos_01_public_nic.private_ip,
    vyos_priv_nic_ip           = aws_network_interface.vyos_01_private_nic.private_ip,
    vyos_bgp_as_number         = var.vyos_bgp_as_number,
    dns                        = var.dns,
    on_prem_public_ip_address  = var.on_prem_public_ip_address,
    on_prem_bgp_as_number      = var.on_prem_bgp_as_number,
    on_prem_subnet_cidr        = var.on_prem_subnet_cidr
  }))

  depends_on = [
    aws_network_interface.vyos_01_public_nic,
    aws_network_interface.vyos_01_private_nic
  ]

  network_interface {
    network_interface_id = aws_network_interface.vyos_01_public_nic.id
    device_index         = 0
  }

  network_interface {
    network_interface_id = aws_network_interface.vyos_01_private_nic.id
    device_index         = 1
  }

  tags = {
    Name = "${var.prefix}-${var.vyos_instance_name}-01"
  }
}

resource "aws_instance" "vyos_02" {
  ami               = data.aws_ami.vyos.id
  # ami               = var.vyos_ami_id
  instance_type     = var.vyos_instance_type
  key_name          = "${var.prefix}-${var.key_pair_name}"
  availability_zone = var.availability_zone_02

  user_data_base64 = base64encode(templatefile("${path.module}/files/vyos_02_user_data.tfpl", {
    transit_vpc_cidr           = var.transit_vpc_cidr,
    data_vpc_public_subnet     = var.data_vpc_public_subnet_cidr,
    vyos_public_ip_address     = aws_eip.vyos_02_eip.public_ip,
    vyos_pub_subnet            = var.transit_vpc_public_subnet_02_cidr,
    vyos_priv_subnet           = var.transit_vpc_private_subnet_02_cidr,
    vyos_01_pub_nic_ip_address = aws_network_interface.vyos_01_public_nic.private_ip,
    vyos_pub_nic_ip            = aws_network_interface.vyos_02_public_nic.private_ip,
    vyos_priv_nic_ip           = aws_network_interface.vyos_02_private_nic.private_ip,
    vyos_bgp_as_number         = var.vyos_bgp_as_number,
    dns                        = var.dns,
    on_prem_public_ip_address  = var.on_prem_public_ip_address,
    on_prem_bgp_as_number      = var.on_prem_bgp_as_number,
    on_prem_subnet_cidr        = var.on_prem_subnet_cidr
  }))

  depends_on = [
    aws_network_interface.vyos_02_public_nic,
    aws_network_interface.vyos_02_private_nic
  ]

  network_interface {
    network_interface_id = aws_network_interface.vyos_02_public_nic.id
    device_index         = 0
  }

  network_interface {
    network_interface_id = aws_network_interface.vyos_02_private_nic.id
    device_index         = 1
  }

  tags = {
    Name = "${var.prefix}-${var.vyos_instance_name}-02"
  }
}

# EC2 Instance in Data VPC

resource "aws_instance" "data_vpc_instance" {
  ami               = data.aws_ami.amazon_linux.id
  availability_zone = var.availability_zone_01
  instance_type     = "t3.micro"
  key_name          = "${var.prefix}-${var.key_pair_name}"

  network_interface {
    network_interface_id = aws_network_interface.data_vpc_instance_nic.id
    device_index         = 0
  }

  tags = {
    Name = "${var.prefix}-data-vpc-instance"
  }
}

# NETWORK INTERFACES

resource "aws_network_interface" "vyos_01_public_nic" {
  subnet_id         = aws_subnet.transit_vpc_public_subnet_01.id
  security_groups   = [aws_security_group.public_sg.id]
  private_ips       = [var.vyos_01_pub_nic_ip_address]
  source_dest_check = false

  tags = {
    Name = "${var.prefix}-${var.vyos_instance_name}-01-PublicNIC"
  }
}

resource "aws_network_interface" "vyos_02_public_nic" {
  subnet_id         = aws_subnet.transit_vpc_public_subnet_02.id
  security_groups   = [aws_security_group.public_sg.id]
  private_ips       = [var.vyos_02_pub_nic_ip_address]
  source_dest_check = false

  tags = {
    Name = "${var.prefix}-${var.vyos_instance_name}-02-PublicNIC"
  }
}

resource "aws_network_interface" "vyos_01_private_nic" {
  subnet_id         = aws_subnet.transit_vpc_private_subnet_01.id
  security_groups   = [aws_security_group.private_sg.id]
  private_ips       = [var.vyos_01_priv_nic_address]
  source_dest_check = false

  tags = {
    Name = "${var.prefix}-${var.vyos_instance_name}-01-PrivateNIC"
  }
}

resource "aws_network_interface" "vyos_02_private_nic" {
  subnet_id         = aws_subnet.transit_vpc_private_subnet_02.id
  security_groups   = [aws_security_group.private_sg.id]
  private_ips       = [var.vyos_02_priv_nic_address]
  source_dest_check = false

  tags = {
    Name = "${var.prefix}-${var.vyos_instance_name}-02-PrivateNIC"
  }
}

resource "aws_network_interface" "data_vpc_instance_nic" {
  subnet_id         = aws_subnet.data_vpc_public_subnet.id
  security_groups   = [aws_security_group.data_vpc_instance_sg.id]
  source_dest_check = false

  tags = {
    Name = "${var.prefix}-Data-VPC-Instance-NIC"
  }
}
