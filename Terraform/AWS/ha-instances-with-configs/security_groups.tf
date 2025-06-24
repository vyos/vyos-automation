# SECURITY GROUP FOR PUBLIC RESOURCES

resource "aws_security_group" "public_sg" {
  name        = join("-", [var.prefix, var.transit_vpc_public_sg_name])
  description = "Security Group for public resources"
  vpc_id      = aws_vpc.transit_vpc.id

  # Allow SSH Traffic
  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow Wireguard Traffic
  ingress {
    description = "Allow Wireguard"
    from_port   = 51820
    to_port     = 51820
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow OpenVPN Traffic
  ingress {
    description = "Allow OpenVPN"
    from_port   = 1194
    to_port     = 1194
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow ESP Traffic
  ingress {
    description = "Allow ESP"
    from_port   = 0
    to_port     = 0
    protocol    = "50"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow IKE Traffic
  ingress {
    description = "Allow IKE"
    from_port   = 500
    to_port     = 500
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow IPSEC Traffic
  ingress {
    description = "Allow IPSEC"
    from_port   = 1701
    to_port     = 1701
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow NAT Traversal
  ingress {
    description = "Allow NAT Traversal"
    from_port   = 4500
    to_port     = 4500
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow ICMP Traffic
  ingress {
    description = "Allow ICMP"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow BGP Traffic
  ingress {
    description = "Allow BGP"
    from_port   = 179
    to_port     = 179
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = join("-", [var.prefix, var.transit_vpc_public_sg_name])
  }
}

# SECURITY GROUP FOR PRIVATE RESOURCES

resource "aws_security_group" "private_sg" {
  name        = join("-", [var.prefix, var.transit_vpc_private_sg_name])
  description = "Security Group for private resources"
  vpc_id      = aws_vpc.transit_vpc.id

  ingress {
    description = "Allow all inbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = join("-", [var.prefix, var.transit_vpc_private_sg_name])
  }
}

# SECURITY GROUP FOR DATA VPC

resource "aws_security_group" "data_vpc_instance_sg" {
  name        = join("-", [var.prefix, var.data_vpc_public_sg_name])
  description = "Security Group for public resources"
  vpc_id      = aws_vpc.data_vpc.id

  # Allow SSH Traffic
  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow Wireguard Traffic
  ingress {
    description = "Allow Wireguard"
    from_port   = 51820
    to_port     = 51820
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow OpenVPN Traffic
  ingress {
    description = "Allow OpenVPN"
    from_port   = 1194
    to_port     = 1194
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow ESP Traffic
  ingress {
    description = "Allow ESP"
    from_port   = 0
    to_port     = 0
    protocol    = "50"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow IKE Traffic
  ingress {
    description = "Allow IKE"
    from_port   = 500
    to_port     = 500
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow IPSEC Traffic
  ingress {
    description = "Allow IPSEC"
    from_port   = 1701
    to_port     = 1701
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow NAT Traversal
  ingress {
    description = "Allow NAT Traversal"
    from_port   = 4500
    to_port     = 4500
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow ICMP Traffic
  ingress {
    description = "Allow ICMP"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = join("-", [var.prefix, var.data_vpc_public_sg_name])
  }
}