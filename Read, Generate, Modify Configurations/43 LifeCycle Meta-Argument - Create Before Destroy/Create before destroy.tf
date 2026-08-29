provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "myec2" {
  # Changing this AMI ID forces a replacement. AWS cannot swap the image on a
  # running instance, so Terraform has to build a new one either way. The
  # lifecycle block below is what decides the order.
  ami           = "ami-0f34c5ae932e6f0e4"
  instance_type = "t2.micro"

  tags = {
    Name = "HelloEarth"
  }

  # Default order on a replacement is destroy the old object, then create the
  # new one, which leaves a gap where neither exists.
  #
  # This flips it. New instance is created first, old one is destroyed only
  # after the replacement is up.
  lifecycle {
    create_before_destroy = true
  }
}