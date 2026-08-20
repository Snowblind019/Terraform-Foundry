# Region has to match the AMI. The AMI in terraform.tfvars is an ap-south-1
# (Mumbai) image, so running this anywhere else will fail with an invalid AMI.
provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "myec2" {
  ami           = var.ami
  instance_type = "t2.micro"
}
