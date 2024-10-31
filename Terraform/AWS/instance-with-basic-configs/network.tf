# VPC

resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "${var.prefix}-${var.vpc_name}"
  }
}

# PUBLIC SUBNET

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.prefix}-${var.vpc_name}-${var.public_subnet_name}"
  }

  depends_on = [aws_internet_gateway.igw]
}

# PRIVATE SUBNET

resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.prefix}-${var.vpc_name}-${var.private_subnet_name}"
  }
}

# INTERNET GATEWAY

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = join("-", [var.prefix, var.igw_name])
  }
}

# ELASTICS IP FOR VYOS

resource "aws_eip" "vyos_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = join("-", [var.prefix, var.vyos_eip_name])
  }
}

resource "aws_eip_association" "vyos_eip_association" {
  allocation_id        = aws_eip.vyos_eip.id
  network_interface_id = aws_network_interface.vyos_public_nic.id
}

# PUBLIC ROUTE TABLE

resource "aws_route_table" "public_rtb" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = join("-", [var.prefix, var.public_rtb_name])
  }
}

resource "aws_route_table_association" "public_rtb_assn" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rtb.id
}