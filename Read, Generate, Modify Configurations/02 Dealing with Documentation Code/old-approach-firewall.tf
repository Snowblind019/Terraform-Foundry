# The OLD way of writing security group rules, back when the documentation
# example showed them nested inside the security group resource itself.
# Applied this against the current provider to confirm it still works.

provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "old_approach" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"

  # The rules live inside the group as blocks, not as separate resources.
  # One resource does everything.
  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443

    # Called "protocol" here. The new style calls this "ip_protocol".
    protocol = "tcp"

    # A list, so one block can cover several source ranges. In the new style
    # it's cidr_ipv4 and takes a single value.
    cidr_blocks = ["10.77.32.50/32"]
  }

  egress {
    # Allow-all in this style is protocol "-1" with both ports set to 0.
    # In the new style I leave the ports out entirely instead.
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
