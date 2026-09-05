# modules/ec2/main.tf
#
# The whole EC2 module. It is plain resource code, exactly what would be
# written anywhere else. Being a module does not change how it is written,
# only where it sits and who references it.
#
# The point of putting it here is that the teams folder can reference this
# without anyone on those teams writing an aws_instance block themselves.

provider "aws" {
  region = "us-east-1"
}

# Region and AMI are both hardcoded at this stage. Nothing is parameterised
# yet.
resource "aws_instance" "myec2" {
  ami           = "ami-0bb84b8ffd87024d8"
  instance_type = "t2.micro"
}