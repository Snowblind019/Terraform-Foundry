# Same Mumbai AMI the course uses, so the region has to match it.
provider "aws" {
  region = "ap-south-1"
}

# instance_type is deliberately left as a variable here. The point of this lab
# is that the value can be set in four different places at once, and the one
# that actually lands is decided by the load order, not by this file.
resource "aws_instance" "myec2" {
  ami           = "ami-0e670eb768a5fc3d4"
  instance_type = var.instance_type
}
