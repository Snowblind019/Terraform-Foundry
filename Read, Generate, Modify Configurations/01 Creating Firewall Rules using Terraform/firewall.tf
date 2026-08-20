# The lecture uses us-east-1 (N. Virginia). Most of my other labs are us-west-2,
# so if I ever go looking for this security group in the console and can't find it,
# check the region selector first.
provider "aws" {
  region = "us-east-1"
}

# Part 1: the security group itself.
# A security group in AWS is just a stateful virtual firewall. This block creates
# an EMPTY one. No inbound rules, no outbound rules. On its own it does nothing,
# which surprised me at first because the console silently adds an allow-all
# outbound rule when you create a group through the UI. Terraform does not.
resource "aws_security_group" "allow_tls" {
  name = "terraform-firewall"

  # Optional. If I leave it out, the AWS provider fills in "Managed by Terraform"
  # for me, because AWS itself requires a description on every security group.
  description = "Managed from Terraform"

  # vpc_id is also optional. Leaving it out drops the group into the default VPC
  # of whatever region I'm in. Fine for a lab, not something I'd do for real.
}

# Part 2: the rules.
# Rules are a SEPARATE resource type from the group. This is the thing to
# remember from this lecture. aws_security_group creates the container,
# aws_vpc_security_group_ingress_rule / _egress_rule create the contents.
#
# ingress = inbound (traffic coming to my resource)
# egress  = outbound (traffic leaving my resource)
# Same vocabulary CloudFormation uses, so it's worth burning in.

# Inbound: allow port 80 from anywhere.
# Note the local name "allow_tls_ipv6" is left over from the HashiCorp docs
# example I copied. It's wrong on both counts: this is port 80, not TLS, and it's
# IPv4, not IPv6. Terraform doesn't care, local names are just labels, but I'd
# name it allow_http_ipv4 in anything I actually maintained.
resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv6" {
  # This is what ties the rule back to the group. It's an attribute reference:
  # aws_security_group (resource type) . allow_tls (local name) . id (attribute).
  security_group_id = aws_security_group.allow_tls.id

  cidr_ipv4 = "0.0.0.0/0"

  # from_port and to_port are a RANGE, not source and destination.
  # Same number in both = a single port. 80 -> 100 would open all 21 ports.
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
}

# Outbound: allow everything.
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_tls.id

  cidr_ipv4 = "0.0.0.0/0"

  # "-1" means all protocols. When I use it I must NOT set from_port or to_port,
  # because all protocols implies all ports. Terraform will error if I do.
  ip_protocol = "-1"
}