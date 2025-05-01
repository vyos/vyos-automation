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
  owners      = ["679593333241"]

  filter {
    name   = "name"
    values = ["VyOS 1.4*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}

# VYOS INSTANCE

resource "aws_instance" "vyos" {
  ami               = data.aws_ami.vyos.id
  instance_type     = var.vyos_instance_type
  key_name          = "${var.prefix}-${var.key_pair_name}"
  availability_zone = var.availability_zone

  user_data_base64 = base64encode(templatefile("${path.module}/files/vyos_user_data.tfpl", {
    private_subnet_cidr       = var.private_subnet_cidr,
    vyos_public_ip_address    = aws_eip.vyos_eip.public_ip,
    vyos_pub_nic_ip           = aws_network_interface.vyos_public_nic.private_ip,
    vyos_priv_nic_ip          = aws_network_interface.vyos_private_nic.private_ip,
    vyos_bgp_as_number        = var.vyos_bgp_as_number,
    dns_1                     = var.dns,
    on_prem_public_ip_address = var.on_prem_public_ip_address,
    on_prem_bgp_as_number     = var.on_prem_bgp_as_number
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
  subnet_id       = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.public_sg.id]
  private_ips     = [var.vyos_pub_nic_ip_address]

  tags = {
    Name = "${var.prefix}-${var.vyos_instance_name}-PublicNIC"
  }
}

resource "aws_network_interface" "vyos_private_nic" {
  subnet_id       = aws_subnet.private_subnet.id
  security_groups = [aws_security_group.private_sg.id]
  private_ips     = [var.vyos_priv_nic_address]

  source_dest_check = false

  tags = {
    Name = "${var.prefix}-${var.vyos_instance_name}-PrivateNIC"
  }
}
