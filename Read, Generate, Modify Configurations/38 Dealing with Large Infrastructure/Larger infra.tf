provider "aws" {
  region = "us-east-1"
}

# The whole point of this lab. This block is about ten lines, but the module
# expands into roughly 35 resources: the VPC itself, three public and three
# private subnets, route tables, a NAT gateway and a VPN gateway.
#
# That is what makes it a stand-in for a large project. Every one of those
# resources is a separate API call on create, and a separate refresh call on
# every plan afterwards.
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name    = "my-vpc"
  version = "5.13.0"
  cidr    = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  # Both of these cost money while they exist. Destroy this lab when done.
  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_security_group" "allow_tls" {
  name        = "terraform-firewall"
  description = "Managed from Terraform"
}

# Inbound on 80 from anywhere.
resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv6" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

# Outbound to anywhere.
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# Added after the first apply, purely so there is one pending change to plan
# against. With everything else already built, a normal plan refreshes all of
# it before reporting this single resource to add:
#
#   terraform plan
#
# With refresh skipped, the plan works off the state file as it stands and
# makes none of those refresh calls:
#
#   terraform plan -refresh=false
#
# Faster, and far fewer API calls. Only safe when the state file is known to
# match the real infrastructure.
resource "aws_security_group" "allow_tls2" {
  name        = "terraform-firewalls"
  description = "Managed from Terraform"
}