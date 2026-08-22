provider "aws" {
  region = "ap-south-1"
}

# No default, so every plan and apply prompts for the value. At the prompt the
# list has to be typed with the brackets, for example ["test", "hello"].
# Swap type = list for type = list(number) to reproduce the last part of the
# video, where only numbers are accepted.
variable "my-list" {
  type = list
}

output "variable_value" {
  value = var.my-list
}

# Second half of the video. Commented out because ami-123 is not a real AMI, so
# it would break an apply. Uncomment this and comment out the variable and
# output above to reproduce the security group part.
#
# resource "aws_instance" "web" {
#   ami           = "ami-123"
#   instance_type = "t3.micro"
#
#   # Brackets are required even for one ID. A bare "sg-1234" fails.
#   vpc_security_group_ids = ["sg-1234"]
# }
