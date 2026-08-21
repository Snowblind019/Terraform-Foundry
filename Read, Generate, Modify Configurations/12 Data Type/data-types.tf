provider "aws" {
  region = "ap-south-1"
}

# Restricting the variable to a data type. Without the type line any value is
# accepted. With it, Terraform rejects anything it cannot convert to a number
# before it ever talks to AWS.
variable "username" {
  type = number
}

resource "aws_iam_user" "lb" {
  name = var.username
}

# Second half of the video, the one that shows why the data type of an argument
# matters. The AMI and the security group ID below are account and region
# specific, so they have to be swapped for real ones before this will apply.
resource "aws_instance" "web" {
  ami           = "ami-0c101f26f147fa7fd"
  instance_type = "t3.micro"

  # Square brackets, not a bare string. The docs call this a list of security
  # group IDs, and passing "sg-..." on its own fails with an incorrect
  # attribute value type error.
  vpc_security_group_ids = ["sg-06dc77ed59c310f03"]
}
