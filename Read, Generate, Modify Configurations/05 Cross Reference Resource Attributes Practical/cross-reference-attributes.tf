provider "aws" {
  region = "us-east-1"
}

resource "aws_eip" "lb" {
  domain = "vpc"
}

resource "aws_security_group" "example" {
  name = "attribute-sg"
}

resource "aws_vpc_security_group_ingress_rule" "example" {
  # Cross reference number one. The rule has to go into a security group, and
  # the sg- ID does not exist until the group is created, so I point at the
  # attribute instead of pasting an ID.
  # Syntax is resource type, local name, attribute.
  security_group_id = aws_security_group.example.id

  # Cross reference number two, allow 443 from the Elastic IP created above.
  #
  # This one needs string interpolation. cidr_ipv4 wants a CIDR block, not a
  # bare address, so the computed IP has to get /32 stuck on the end. Terraform
  # works out what is inside ${ } first, then leaves the rest of the string
  # alone. Without this the apply fails with "must be a valid IPv4 CIDR block".
  cidr_ipv4 = "${aws_eip.lb.public_ip}/32"

  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}

# Terraform builds these in order on its own because of the references above:
# Elastic IP, then security group, then the rule.
