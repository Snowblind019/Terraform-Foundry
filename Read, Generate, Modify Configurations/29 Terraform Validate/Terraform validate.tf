# Starting point, a valid file. terraform validate reports success on it.
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "myec2" {
  ami           = "ami-00c39f71452c08778"
  instance_type = "t2.micro"
}

# Break it in two ways to see what validate catches.
#
# 1. Unsupported argument. Add a line inside the resource block that the
#    resource type does not accept:
#      sky = "blue"
#
# 2. Reference to an undeclared variable. Swap the instance_type value for a
#    variable that was never defined:
#      instance_type = var.instancetype