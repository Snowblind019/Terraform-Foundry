# Elastic IP. Nothing references it directly in its own block, but the ingress
# rule below uses its public_ip, which is what creates the dependency.
resource "aws_eip" "lb" {
  domain = "vpc"
}

resource "aws_security_group" "example" {
  name = "attribute-sg"
}

# Two dependencies come out of this block in the graph:
#   security_group_id -> aws_security_group.example
#   cidr_ipv4         -> aws_eip.lb
# The rule allows 443 from whatever public IP the EIP gets, /32 so it is that
# single address only.
resource "aws_vpc_security_group_ingress_rule" "example" {
  security_group_id = aws_security_group.example.id

  cidr_ipv4   = "${aws_eip.lb.public_ip}/32"
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}

# No references to anything above, so in the graph this sits by itself with
# only the provider above it.
resource "aws_instance" "web" {
  ami           = "ami-0440d3b780d96b29d"
  instance_type = "t2.micro"
}

# Commands used:
#
#   terraform init
#   terraform graph
#   terraform graph | dot -Tsvg > graph.svg
#
# dot comes from graphviz. On Fedora: sudo dnf install graphviz