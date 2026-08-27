provider "aws" {
  region = "ap-south-1"
}

variable "environment" {
  default = "production"
}

variable "region" {
  default = "ap-south-1"
}

# The condition is checked, and one of the two values after it is used. The ?
# separates the condition from the true value, the : separates true from false.
# Both conditions have to hold here because of the &&. environment is production
# but region is ap-south-1, so the condition is false and t2.micro is used.
resource "aws_instance" "myec2" {
  ami           = "ami-00c39f71452c08778"
  instance_type = var.environment == "production" && var.region == "us-east-1" ? "m5.large" : "t2.micro"
}

# The earlier versions from the same video, kept for reference. Each one
# replaces the instance_type line above.
#
# Straight equality. development gets the small instance, anything else gets
# the large one:
#   instance_type = var.environment == "development" ? "t2.micro" : "m5.large"
#
# Same thing inverted with !=. Reads backwards but does the same job, the
# true value is now what applies when environment is not development:
#   instance_type = var.environment != "development" ? "t2.micro" : "m5.large"
#
# Checking for an empty value. True only when the variable has no value set:
#   instance_type = var.environment == "" ? "t2.micro" : "m5.large"