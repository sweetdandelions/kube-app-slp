# Create AWS Internet Gateway and attach it to the VPC
# Allows instances in the public subnets to access the Internet

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.main-kube_vpc.id

  tags = {
    Name = "Internet Gateway Groundplex"
  }
}