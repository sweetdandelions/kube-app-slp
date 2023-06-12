# Create public subnets
resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.main-kube_vpc.id

  # Number of public subnets
  count                   = length(var.num_public_sub)
  cidr_block              = element(var.num_public_sub, count.index)
  availability_zone       = data.aws_availability_zones.azs.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    "Name"                                          = "Public subnet ${count.index}",
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared",
    "kubernetes.io/role/elb"                        = 1
  }
}

# Create private subnets
resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.main-kube_vpc.id

  count                   = length(var.num_private_sub)
  cidr_block              = element(var.num_private_sub, count.index)
  availability_zone       = data.aws_availability_zones.azs.names[count.index]
  map_public_ip_on_launch = false

  tags = {
    "Name"                                          = "Private subnet ${count.index}",
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned",
    "kubernetes.io/role/internal-elb"               = 1
  }
}