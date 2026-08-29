provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "myec2" {
  ami           = "ami-0f34c5ae932e6f0e4"
  instance_type = "t2.micro"

  tags = {
    Name = "HelloWorld"
  }

  lifecycle {
    # Named list version. Terraform leaves these two attributes alone and still
    # manages everything else normally. Changing the instance type on the
    # stopped instance in the console no longer shows up in plan once
    # instance_type is in here.
    #
    # ignore_changes = [tags, instance_type]

    # The all keyword, for when listing every attribute is impractical.
    # Terraform will still create and destroy this object, but it will never
    # propose an update to it.
    #
    # Worth being clear on what that means: this ignores changes made in the
    # tf file too, not just drift from outside. Editing the Name tag above and
    # running plan comes back with no changes.
    ignore_changes = all
  }
}