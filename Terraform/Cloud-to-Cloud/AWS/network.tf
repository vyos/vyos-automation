# VPC AND PEERING

resource "aws_vpc" "transit_vpc" {
  cidr_block       = var.transit_vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "${var.prefix}-${var.transit_vpc_name}"
  }
}

# PUBLIC AND PRIVATE SUBNETS FOR TRANSIT VPC

resource "aws_subnet" "transit_vpc_public_subnet" {
  vpc_id                  = aws_vpc.transit_vpc.id
  cidr_block              = var.transit_vpc_public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.prefix}-${var.transit_vpc_name}-${var.transit_vpc_public_subnet_name}"
  }

  depends_on = [aws_internet_gateway.transit_vpc_igw]
}

resource "aws_subnet" "transit_vpc_private_subnet" {
  vpc_id                  = aws_vpc.transit_vpc.id
  cidr_block              = var.transit_vpc_private_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.prefix}-${var.transit_vpc_name}-${var.transit_vpc_private_subnet_name}"
  }
}

# INTERNET GATEWAYS

resource "aws_internet_gateway" "transit_vpc_igw" {
  vpc_id = aws_vpc.transit_vpc.id

  tags = {
    Name = join("-", [var.prefix, var.transit_vpc_igw_name])
  }
}

# ELASTICS IP FOR VYOS INSTANCES

resource "aws_eip" "vyos_eip" {
  domain = "vpc"

  tags = {
    Name = join("-", [var.prefix, var.vyos_eip_name])
  }
}

resource "aws_eip_association" "vyos_eip_association" {
  allocation_id        = aws_eip.vyos_eip.id
  network_interface_id = aws_network_interface.vyos_public_nic.id
}

# TRANSIT VPC ROUTE PUBLIC TABLES

resource "aws_route_table" "transit_vpc_public_rtb" {
  vpc_id = aws_vpc.transit_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.transit_vpc_igw.id
  }

  tags = {
    Name = join("-", [var.prefix, var.transit_vpc_public_rtb_name])
  }

}

resource "aws_route_table_association" "transit_vpc_public_rtb_assn" {
  subnet_id      = aws_subnet.transit_vpc_public_subnet.id
  route_table_id = aws_route_table.transit_vpc_public_rtb.id
}

resource "aws_route_table" "transit_vpc_private_rtb" {
  vpc_id = aws_vpc.transit_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.transit_vpc_igw.id
  }

   route {
    cidr_block = "192.168.0.0/16"
    network_interface_id = aws_network_interface.vyos_private_nic.id
  }

  tags = {
    Name = join("-", [var.prefix, var.transit_vpc_private_rtb_name])
  }

}

resource "aws_route_table_association" "transit_vpc_private_rtb_assn" {
  subnet_id      = aws_subnet.transit_vpc_private_subnet.id
  route_table_id = aws_route_table.transit_vpc_private_rtb.id
}