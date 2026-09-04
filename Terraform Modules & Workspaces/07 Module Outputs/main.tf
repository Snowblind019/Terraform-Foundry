# modules/ec2/main.tf
#
# The child module. Just an EC2 instance, plus an output.

resource "aws_instance" "myec2" {
  ami           = "ami-08a0d1e16fc3f61ea"
  instance_type = "t2.micro"
}

# Without this block nothing about the instance is visible outside the
# module. Trying module.ec2.id from the root module fails validation with
# "this object does not have an attribute named id", even though the
# aws_instance resource does have an id attribute.
#
# The value is the attribute from the aws_instance attribute reference
# docs. "id" is the ID of the instance.
output "instance_id" {
  value = aws_instance.myec2.id
}