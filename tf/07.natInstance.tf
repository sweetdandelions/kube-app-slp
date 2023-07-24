#---------------------------------------------------------------------#
#                       NAT EC2 security group                        #
#---------------------------------------------------------------------#
# https://docs.aws.amazon.com/vpc/latest/userguide/VPC_NAT_Instance.html#NATSG

resource "aws_security_group" "NAT_SG" {
  name        = "NAT_SG_EC2"
  description = "Security group for NAT instance"
  vpc_id      = aws_vpc.main-kube_vpc.id
}

resource "aws_security_group_rule" "NAT_icmp_ingress" {
  description       = "Inbound traffic on ICMP (ping) from vpc cidr"
  cidr_blocks       = ["0.0.0.0/0"]
  protocol          = "icmp"
  from_port         = 0
  to_port           = 0
  security_group_id = aws_security_group.NAT_SG.id
  type              = "ingress"
}

resource "aws_security_group_rule" "NAT_80_ingress" {
  description       = "HTTP inbound traffic from private subnets"
  cidr_blocks       = var.num_private_sub
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  security_group_id = aws_security_group.NAT_SG.id
  type              = "ingress"
}

resource "aws_security_group_rule" "NAT_80_egress" {
  description       = "Outbound HTTP traffic to any destination"
  cidr_blocks       = ["0.0.0.0/0"]
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  security_group_id = aws_security_group.NAT_SG.id
  type              = "egress"
}

resource "aws_security_group_rule" "NAT_443_ingress" {
  description       = "HTTPS inbound traffic from private subnets"
  cidr_blocks       = var.num_private_sub
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  security_group_id = aws_security_group.NAT_SG.id
  type              = "ingress"
}

resource "aws_security_group_rule" "NAT_443_egress" {
  description       = "Outbound HTTPS traffic to any destination"
  cidr_blocks       = ["0.0.0.0/0"]
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  security_group_id = aws_security_group.NAT_SG.id
  type              = "egress"
}

resource "aws_security_group_rule" "NAT_ssh_ingress" {
  description       = "Allow SSH from workstation on port 22"
  cidr_blocks       = [local.workstation-external-cidr]
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  security_group_id = aws_security_group.NAT_SG.id
  type              = "ingress"
}

resource "aws_security_group_rule" "NAT_8081_ingress" {
  description       = "Snaplex inbound"
  cidr_blocks       = var.num_private_sub
  protocol          = "tcp"
  from_port         = 8081
  to_port           = 8081
  security_group_id = aws_security_group.NAT_SG.id
  type              = "ingress"
}
#-------------------------------------------------------------

resource "aws_network_interface" "network_interface" {
  subnet_id         = tolist(aws_subnet.public_subnet.*.id)[0]
  source_dest_check = false
  security_groups   = [aws_security_group.NAT_SG.id]

  tags = {
    Name = "NAT instance network interface"
  }
}

resource "aws_eip" "nat_public_ip" {
  instance = aws_instance.NAT_EC2[0].id
  domain   = "vpc"

  depends_on = [aws_internet_gateway.IGW]
}

# NAT instance
resource "aws_instance" "NAT_EC2" {

  instance_type = var.nat_instance
  ami           = var.ami
  count         = 1
  key_name      = aws_key_pair.key.id

  network_interface {
    network_interface_id = aws_network_interface.network_interface.id
    device_index         = 0
  }

  /*user_data = <<-EOF
  #!/bin/bash
  echo 0 > /proc/sys/net/ipv4/ip_forward
  iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
  EOF*/

  #user_data = "${file("userdata.sh")}"

  # Identation to far left
  user_data = <<-EOF
#!/bin/bash
# Logging
set -x
exec > >(tee /var/log/user-data.log|logger -t user-data ) 2>&1
echo BEGIN
date '+%Y-%m-%d %H:%M:%S'
# apt update && apt upgrade -y
/bin/echo "Hello, World!" >> hello.txt
# Main
/bin/echo 1 > /proc/sys/net/ipv4/ip_forward
/usr/sbin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
EOF

  tags = {
    Name = "NAT instance"
    Role = "NAT"
  }
}
