provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "myec2" {
  ami           = "ami-0f34c5ae932e6f0e4"
  instance_type = "t2.micro"

  tags = {
    Name = "HelloEarth"
  }

  # terraform destroy on this resource now fails with an error instead of
  # prompting for confirmation. Meant for things that are expensive or painful
  # to rebuild, databases being the usual case, especially where applies run
  # from a script or a CI job with nobody watching.
  #
  # The protection only holds while this block is in the configuration. Delete
  # the whole resource block and the next apply destroys the instance, because
  # there is nothing left in the config to say it is protected.
  lifecycle {
    prevent_destroy = true
  }
}