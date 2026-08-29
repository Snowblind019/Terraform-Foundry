provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "myec2" {
  # Amazon Linux AMI. Swapping this for a Windows AMI does not update in place,
  # AWS does not allow it, so plan shows the instance being destroyed and
  # recreated with a forced replacement note.
  ami           = "ami-0f34c5ae932e6f0e4"
  instance_type = "t2.micro"

  # Changing this value on its own is an in-place update. The instance stays,
  # only the tag changes.
  tags = {
    Name = "HelloEarth"
  }

  # The meta-argument. Without this block, a tag added by hand in the AWS
  # console gets removed on the next apply, because Terraform pulls the live
  # resource back to match the configuration.
  #
  # ignore_changes tells Terraform to skip the listed attributes when it
  # compares the two, so manual tag changes are left alone. Takes a list, so
  # more attributes can go in the brackets.
  lifecycle {
    ignore_changes = [tags]
  }
}