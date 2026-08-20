provider "aws" {
  region = "us-east-1"
}

resource "aws_eip" "lb" {
  domain = "vpc"
}

# Prints the value on the CLI after apply instead of me going to the console
# to look it up. "public-ip" is just a label, I can call it anything.
output "public-ip" {
  value = aws_eip.lb.public_ip
}

# Two other versions shown in the video.

# Build a full URL around the value. Needs ${ } because the attribute is part
# of a bigger string.
# output "public-ip" {
#   value = "https://${aws_eip.lb.public_ip}:8080"
# }

# Leave the attribute off and it prints every attribute the resource has.
# output "public-ip" {
#   value = aws_eip.lb
# }
