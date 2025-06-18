# TRANSIT GATEWAY

resource "aws_ec2_transit_gateway" "tgw" {
  description                     = "Main Transit Gateway"
  amazon_side_asn                 = 64512
  auto_accept_shared_attachments  = "enable"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"

  tags = {
    Name = "${var.prefix}-tgw"
  }
}

# TRANSIT GATEWAY ATTACHMENT

resource "aws_ec2_transit_gateway_vpc_attachment" "transit_vpc_attachment" {
  subnet_ids         = [aws_subnet.transit_vpc_private_subnet_01.id, aws_subnet.transit_vpc_private_subnet_02.id]
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = aws_vpc.transit_vpc.id

  tags = {
    Name = "${var.prefix}-${var.transit_vpc_name}-attachment"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "data_vpc_attachment" {
  subnet_ids         = [aws_subnet.data_vpc_private_subnet.id]
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = aws_vpc.data_vpc.id

  tags = {
    Name = "${var.prefix}-${var.data_vpc_name}-attachment"
  }
}

resource "aws_ec2_transit_gateway_connect" "tgw_connect" {
  transport_attachment_id = aws_ec2_transit_gateway_vpc_attachment.transit_vpc_attachment.id
  transit_gateway_id      = aws_ec2_transit_gateway.tgw.id

  tags = {
    Name = "${var.prefix}-${var.transit_vpc_name}-connect"
  }
}

# TRANSIT GATEWAY ROUTE

resource "aws_ec2_transit_gateway_route_table" "tgw_rt" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id

  tags = {
    Name = "${var.prefix}-tgw-rtb"
  }
}

resource "aws_ec2_transit_gateway_route" "azure" {
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_rt.id
  destination_cidr_block         = var.on_prem_subnet_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.transit_vpc_attachment.id
}

# TRANSIT GATEWAY ASSOSIATION and PROPAGATION

resource "aws_ec2_transit_gateway_route_table_association" "transit_vpc_rt_assoc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.transit_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_rt.id
}

resource "aws_ec2_transit_gateway_route_table_association" "data_vpc_rt_assoc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.data_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_rt.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "transit_vpc_rt_prop" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.transit_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_rt.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "data_vpc_rt_prop" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.data_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_rt.id
}
