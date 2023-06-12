
# Define CIDR (Classless Inter-Domain Routing) block
# CIDR is based on a concept called subnetting. Subnetting allows you to take a class, 
# or block of IP addresses and further chop it up into smaller blocks or groups of IPs. 
# CIDR and subnetting are virtually the same thing.
variable "vpc_cidr_block" {
  default     = "10.0.0.0/16"
  description = "Default IP range (65,536) for the VPC"
  type        = string
}

/* Subnets cidr bits
variable "subnet_cidr_bits" {
  description = "Number of subnet bits for the CIDR calculation. For example, specifying a value 8 for this parameter will create a CIDR with a mask of /24."
  type        = number
  default     = 8
}*/

# Define CIDR range and count of Public subnets
variable "num_private_sub" {
  description = "A list of private subnet CIDRs to deploy inside the VPC"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

# Define CIDR range and count of Public subnets
variable "num_public_sub" {
  description = "A list of public subnet CIDRs to deploy inside the VPC"
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

# Define default region
variable "region" {
  default     = "us-east-1"
  description = "Default region N.Virginia"
  type        = string
}

# Provide available AZs for the region
data "aws_availability_zones" "azs" {
  state = "available"
}

variable "eks_cluster_name" {
  default = "eks_groudplex_01"
}

variable "cluster_version" {
  default = "1.25"
}

# Ubuntu ami
variable "ami" {
  default = "ami-007855ac798b5175e" #Ubuntu
  # Amazon Linux "ami-06e46074ae430fba6" 
  # EOL NAT ami -> "ami-04bc0c8c817569ffe"
  description = "AMI for NAT EC2"
}

variable "ami_type" {
  default     = "AL2_x86_64"
  description = "AMI type"
}

variable "nat_instance" {
  default = "t2.micro"
  type    = string
}

variable "cluster_instance" {
  default = ["t3.medium"]
  type    = list(any)
}

variable "capacity" {
  default = "ON_DEMAND"
}

variable "disk" {
  default = 20
}

# Get your public IP
data "http" "workstation_public_ip" {
  url = "http://icanhazip.com/"
}

locals {
  workstation-external-cidr = "${chomp(data.http.workstation_public_ip.response_body)}/32"
}

variable "public_key_path" {
  default = "~/.ssh/id_rsa.pub"
}

variable "helm_chart_namespace" {
  default = "monitoring"
}

/*locals {
  user_data_values = {
    cluster_name = var.eks_cluster_name
    cluster_ca = var.eks-cluster-certificate-authority
    api_server_url = var.eks_cluster_endpoint
  }
}*/