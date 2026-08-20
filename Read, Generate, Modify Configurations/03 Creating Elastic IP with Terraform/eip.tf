provider "aws" {
  region = "us-east-1"
}

# Allocates an Elastic IP, which is a static public IPv4 address in AWS.
# Same thing as clicking Allocate Elastic IP address in the console.
resource "aws_eip" "lb" {
  domain = "vpc"
}

# The documentation example also has an "instance" argument for attaching the
# EIP to an EC2 instance. The docs list it as optional and I am only allocating
# the address here, nothing to attach it to, so I left it out.
