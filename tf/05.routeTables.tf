# Public route table
resource "aws_route_table" "public_route_tbl" {
  vpc_id = aws_vpc.main-kube_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }

  tags = {
    "Name" = "Route table for public subnets"
  }
}

# Private route table
resource "aws_route_table" "private_route_tbl" {
  vpc_id = aws_vpc.main-kube_vpc.id

  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = aws_network_interface.network_interface.id
  }

  tags = {
    "Name" = "Route table for private subnets"
  }
}
