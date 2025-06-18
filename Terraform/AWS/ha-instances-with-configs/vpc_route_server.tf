# VPC ROUTE SERVER
resource "aws_vpc_route_server" "vyos_route_server" {
  amazon_side_asn = 65011
  tags = {
    Name = join("-", [var.prefix, "vyos-route-server"])
  }
}

# VPC ROUTE SERVER ASSOCIATION
resource "aws_vpc_route_server_vpc_association" "vyos_association" {
  route_server_id = aws_vpc_route_server.vyos_route_server.route_server_id
  vpc_id          = aws_vpc.transit_vpc.id
}

# VPC ROUTE SERVER ENDPOINTS
resource "aws_vpc_route_server_endpoint" "vyos_01_endpoint" {
  route_server_id = aws_vpc_route_server.vyos_route_server.route_server_id
  subnet_id       = aws_subnet.transit_vpc_private_subnet_01.id

  tags = {
    Name = join("-", [var.prefix, "vyos-route-server", "vyos-01"])
  }

  depends_on = [
    aws_vpc_route_server_vpc_association.vyos_association
  ]
}

resource "aws_vpc_route_server_endpoint" "vyos_02_endpoint" {
  route_server_id = aws_vpc_route_server.vyos_route_server.route_server_id
  subnet_id       = aws_subnet.transit_vpc_private_subnet_02.id

  tags = {
    Name = join("-", [var.prefix, "vyos-route-server", "vyos-02"])
  }

  depends_on = [
    aws_vpc_route_server_vpc_association.vyos_association
  ]

}

# VPC ROUTE SERVER PEERS
resource "aws_vpc_route_server_peer" "vyos_01_peer" {
  route_server_endpoint_id = aws_vpc_route_server_endpoint.vyos_01_endpoint.route_server_endpoint_id
  peer_address             = aws_network_interface.vyos_01_private_nic.private_ip
  bgp_options {
    peer_asn                = var.vyos_bgp_as_number
    peer_liveness_detection = "bfd"
  }

  tags = {
    Name = "vyos-01-peer"
  }

  depends_on = [
    aws_vpc_route_server_endpoint.vyos_01_endpoint
  ]
}


resource "aws_vpc_route_server_peer" "vyos_02_peer" {
  route_server_endpoint_id = aws_vpc_route_server_endpoint.vyos_02_endpoint.route_server_endpoint_id
  peer_address             = aws_network_interface.vyos_02_private_nic.private_ip
  bgp_options {
    peer_asn                = var.vyos_bgp_as_number
    peer_liveness_detection = "bfd"
  }

  tags = {
    Name = "vyos-02-peer"
  }

  depends_on = [
    aws_vpc_route_server_endpoint.vyos_02_endpoint
  ]
}

# VPC ROUTE SERVER PROPOGATIONS
resource "aws_vpc_route_server_propagation" "vyos_01_propagation" {
  route_server_id = aws_vpc_route_server.vyos_route_server.route_server_id
  route_table_id  = aws_route_table.transit_vpc_private_rtb_01.id

  depends_on = [
    aws_vpc_route_server_peer.vyos_01_peer,
    aws_route_table.transit_vpc_private_rtb_01
  ]
}

resource "aws_vpc_route_server_propagation" "vyos_02_propagation" {
  route_server_id = aws_vpc_route_server.vyos_route_server.route_server_id
  route_table_id  = aws_route_table.transit_vpc_private_rtb_02.id

  depends_on = [
    aws_vpc_route_server_peer.vyos_02_peer,
    aws_route_table.transit_vpc_private_rtb_02
  ]
}