resource "aws_route_table_association" "public_tbl_assc" {
  count          = length(var.num_public_sub)
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public_route_tbl.id
}

resource "aws_route_table_association" "private_tbl_assc" {
  count          = length(var.num_private_sub)
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = aws_route_table.private_route_tbl.id
}