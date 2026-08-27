# The hardcoded version, kept as the demonstration of the problem.
# The AMI ID below was copied out of the EC2 console in North Virginia, so it
# only resolves in us-east-1. Pointing the provider at ap-south-1 while leaving
# the ID alone is what triggers the failure.
provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "web" {
  ami           = "ami-id-copied-from-us-east-1"
  instance_type = "t2.micro"
}