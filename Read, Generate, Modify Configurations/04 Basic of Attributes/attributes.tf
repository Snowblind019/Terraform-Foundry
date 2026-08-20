provider "aws" {
  region = "us-east-1"
}

# Two resources here so there is more than one thing to look at in the state
# file afterwards.

resource "aws_eip" "lb" {
  domain = "vpc"
}

resource "aws_instance" "web" {
  # AMI IDs are per region, so this one only works in us-east-1.
  ami           = "ami-0440d3b780d96b29d"
  instance_type = "t2.micro"
}

# Nothing in this file sets an attribute. ami and instance_type are arguments,
# things I decide. The attributes are what AWS fills in after the apply, like
# the instance ID and the public IP, and those show up in terraform.tfstate.
