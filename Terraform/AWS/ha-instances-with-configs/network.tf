# VPC AND PEERING

resource "aws_vpc" "transit_vpc" {
  cidr_block       = var.transit_vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "${var.prefix}-${var.transit_vpc_name}"
  }
}

resource "aws_vpc" "data_vpc" {
  cidr_block       = var.data_vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "${var.prefix}-${var.data_vpc_name}"
  }
}

# PUBLIC AND PRIVATE SUBNETS FOR TRANSIT VPC

resource "aws_subnet" "transit_vpc_public_subnet_01" {
  vpc_id                  = aws_vpc.transit_vpc.id
  cidr_block              = var.transit_vpc_public_subnet_01_cidr
  availability_zone       = var.availability_zone_01
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.prefix}-${var.transit_vpc_name}-${var.transit_vpc_public_subnet_name}-01"
  }

  depends_on = [aws_internet_gateway.transit_vpc_igw]
}

resource "aws_subnet" "transit_vpc_public_subnet_02" {
  vpc_id                  = aws_vpc.transit_vpc.id
  cidr_block              = var.transit_vpc_public_subnet_02_cidr
  availability_zone       = var.availability_zone_02
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.prefix}-${var.transit_vpc_name}-${var.transit_vpc_public_subnet_name}-02"
  }

  depends_on = [aws_internet_gateway.transit_vpc_igw]
}

resource "aws_subnet" "transit_vpc_private_subnet_01" {
  vpc_id                  = aws_vpc.transit_vpc.id
  cidr_block              = var.transit_vpc_private_subnet_01_cidr
  availability_zone       = var.availability_zone_01
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.prefix}-${var.transit_vpc_name}-${var.transit_vpc_private_subnet_name}-01"
  }
}

resource "aws_subnet" "transit_vpc_private_subnet_02" {
  vpc_id                  = aws_vpc.transit_vpc.id
  cidr_block              = var.transit_vpc_private_subnet_02_cidr
  availability_zone       = var.availability_zone_02
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.prefix}-${var.transit_vpc_name}-${var.transit_vpc_private_subnet_name}-02"
  }
}


# PUBLIC AND PRIVATE SUBNETS FOR DATA VPC

resource "aws_subnet" "data_vpc_public_subnet" {
  vpc_id                  = aws_vpc.data_vpc.id
  cidr_block              = var.data_vpc_public_subnet_cidr
  availability_zone       = var.availability_zone_01
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.prefix}-${var.data_vpc_name}-${var.data_vpc_public_subnet_name}"
  }

  depends_on = [aws_internet_gateway.data_vpc_igw]
}

resource "aws_subnet" "data_vpc_private_subnet" {
  vpc_id                  = aws_vpc.data_vpc.id
  cidr_block              = var.data_vpc_private_subnet_cidr
  availability_zone       = var.availability_zone_01
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.prefix}-${var.data_vpc_name}-${var.data_vpc_private_subnet_name}"
  }
}


# INTERNET GATEWAYS

resource "aws_internet_gateway" "transit_vpc_igw" {
  vpc_id = aws_vpc.transit_vpc.id

  tags = {
    Name = join("-", [var.prefix, var.transit_vpc_igw_name])
  }
}

resource "aws_internet_gateway" "data_vpc_igw" {
  vpc_id = aws_vpc.data_vpc.id

  tags = {
    Name = join("-", [var.prefix, var.data_vpc_igw_name])
  }
}


# ELASTICS IP FOR VYOS INSTANCES

resource "aws_eip" "vyos_01_eip" {
  domain = "vpc"

  tags = {
    Name = join("-", [var.prefix, var.vyos_eip_name, "01"])
  }
}

resource "aws_eip_association" "vyos_eip_association_01" {
  allocation_id        = aws_eip.vyos_01_eip.id
  network_interface_id = aws_network_interface.vyos_01_public_nic.id
}

resource "aws_eip" "vyos_02_eip" {
  domain = "vpc"

  tags = {
    Name = join("-", [var.prefix, var.vyos_eip_name, "02"])
  }
}

resource "aws_eip_association" "vyos_eip_association_02" {
  allocation_id        = aws_eip.vyos_02_eip.id
  network_interface_id = aws_network_interface.vyos_02_public_nic.id
}


# ELASTICS IP FOR TEST INSTANCE

resource "aws_eip" "data_vpc_instance_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.data_vpc_igw]

  tags = {
    Name = "${var.prefix}-data-vpc-instance-eip"
  }
}

resource "aws_eip_association" "data_vpc_instance_eip_assoc" {
  allocation_id        = aws_eip.data_vpc_instance_eip.id
  network_interface_id = aws_network_interface.data_vpc_instance_nic.id
}


# TRANSIT VPC ROUTE PUBLIC TABLES

resource "aws_route_table" "transit_vpc_public_rtb_01" {
  vpc_id = aws_vpc.transit_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.transit_vpc_igw.id
  }

  route {
    cidr_block         = var.data_vpc_cidr
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  }

  route {
    cidr_block           = var.on_prem_subnet_cidr
    network_interface_id = aws_network_interface.vyos_02_public_nic.id
  }

  tags = {
    Name = join("-", [var.prefix, var.transit_vpc_public_rtb_01_name])
  }

}

resource "aws_route_table_association" "transit_vpc_public_rtb_01_assn" {
  subnet_id      = aws_subnet.transit_vpc_public_subnet_01.id
  route_table_id = aws_route_table.transit_vpc_public_rtb_01.id
}


resource "aws_route_table" "transit_vpc_public_rtb_02" {
  vpc_id = aws_vpc.transit_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.transit_vpc_igw.id
  }

  route {
    cidr_block         = var.data_vpc_cidr
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  }

  route {
    cidr_block           = var.on_prem_subnet_cidr
    network_interface_id = aws_network_interface.vyos_01_public_nic.id
  }

  tags = {
    Name = join("-", [var.prefix, var.transit_vpc_public_rtb_02_name])
  }

}

resource "aws_route_table_association" "transit_vpc_public_rtb_02_assn" {
  subnet_id      = aws_subnet.transit_vpc_public_subnet_02.id
  route_table_id = aws_route_table.transit_vpc_public_rtb_02.id
}


# TRANSIT VPC ROUTE PRIVATE TABLES

resource "aws_route_table" "transit_vpc_private_rtb_01" {
  vpc_id = aws_vpc.transit_vpc.id


  route {
    cidr_block         = var.data_vpc_cidr
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  }

  tags = {
    Name = join("-", [var.prefix, var.transit_vpc_private_rtb_01_name])
  }

}

resource "aws_route_table_association" "transit_vpc_private_rtb_01_assn" {
  subnet_id      = aws_subnet.transit_vpc_private_subnet_01.id
  route_table_id = aws_route_table.transit_vpc_private_rtb_01.id
}


resource "aws_route_table" "transit_vpc_private_rtb_02" {
  vpc_id = aws_vpc.transit_vpc.id


  route {
    cidr_block         = var.data_vpc_cidr
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  }

  tags = {
    Name = join("-", [var.prefix, var.transit_vpc_private_rtb_02_name])
  }

}

resource "aws_route_table_association" "transit_vpc_private_rtb_02_assn" {
  subnet_id      = aws_subnet.transit_vpc_private_subnet_02.id
  route_table_id = aws_route_table.transit_vpc_private_rtb_02.id
}


# DATA VPC PUBLIC ROUTE TABLE

resource "aws_route_table" "data_vpc_public_rtb" {
  vpc_id = aws_vpc.data_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.data_vpc_igw.id
  }

  route {
    cidr_block         = var.transit_vpc_cidr
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  }

  route {
    cidr_block         = var.on_prem_subnet_cidr
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  }

  tags = {
    Name = join("-", [var.prefix, var.data_vpc_public_rtb_name])
  }

}

resource "aws_route_table_association" "data_vpc_public_rtb_assn" {
  subnet_id      = aws_subnet.data_vpc_public_subnet.id
  route_table_id = aws_route_table.data_vpc_public_rtb.id
}


# DATA VPC PRIVATE ROUTE TABLE

resource "aws_route_table" "data_vpc_private_rtb" {
  vpc_id = aws_vpc.data_vpc.id

  route {
    cidr_block         = var.transit_vpc_cidr
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  }

  route {
    cidr_block         = var.on_prem_subnet_cidr
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  }

  tags = {
    Name = join("-", [var.prefix, var.data_vpc_private_rtb_name])
  }

}

resource "aws_route_table_association" "data_vpc_private_rtb_assn" {
  subnet_id      = aws_subnet.data_vpc_private_subnet.id
  route_table_id = aws_route_table.data_vpc_private_rtb.id
}
