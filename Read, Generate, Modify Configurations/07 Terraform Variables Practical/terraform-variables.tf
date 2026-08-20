provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "allow_tls" {
  name        = "terraform-firewall"
  description = "Managed from Terraform"
}

# Three rules, all allowing the same VPN IP on different ports. Before the
# change, the IP was typed out three times and the ports were hardcoded.
# Now every value that could change lives in variables.tf instead.

resource "aws_vpc_security_group_ingress_rule" "app_port" {
  security_group_id = aws_security_group.allow_tls.id

  # var. tells Terraform to go find a variable by this name.
  cidr_ipv4 = var.vpn_ip

  from_port   = var.app_port
  to_port     = var.app_port
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "ssh_port" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = var.vpn_ip
  from_port         = var.ssh_port
  to_port           = var.ssh_port
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "ftp_port" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = var.vpn_ip
  from_port         = var.ftp_port
  to_port           = var.ftp_port
  ip_protocol       = "tcp"
}