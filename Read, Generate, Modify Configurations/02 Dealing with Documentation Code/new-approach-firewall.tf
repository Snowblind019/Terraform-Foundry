# The NEW way, which is what the documentation shows today. The group and the
# rules are separate resources. Same end result as old-approach-firewall.tf.

provider "aws" {
  region = "us-east-1"
}

# Not part of the documentation example, but the example references aws_vpc.main
# without ever defining it, so plan fails with a reference to an undeclared
# resource. Adding it here so the file actually runs.
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  # Needed for the IPv6 rules below. Without it, ipv6_cidr_block is null.
  assign_generated_ipv6_cidr_block = true

  tags = {
    Name = "terraform-lab-vpc"
  }
}

# Just the group. No rules in it.
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "allow_tls"
  }
}

# Inbound 443, allowed from the VPC's own CIDR range.
resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = aws_vpc.main.cidr_block
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

# The same rule for IPv6. Each rule resource takes one CIDR, so covering both
# IPv4 and IPv6 means two resources.
resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv6" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv6         = aws_vpc.main.ipv6_cidr_block
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

# Outbound allow-all. ip_protocol "-1" means all protocols, and no from_port or
# to_port is given. Compare to the old file where allow-all sets both to 0.
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
