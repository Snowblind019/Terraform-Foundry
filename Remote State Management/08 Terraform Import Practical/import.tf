# The only file you write by hand in this lab. Terraform writes the rest.

provider "aws" {
  # Has to match the region the manually created security group actually lives in.
  # North Virginia is us-east-1. Mumbai would be ap-south-1. If this does not match,
  # Terraform will not find the resource by ID.
  region = "us-east-1"
}

import {
  # Where the generated code will be written. You choose this address, not Terraform.
  # aws_security_group is the resource type from the AWS provider docs, mysg is a local
  # name of your choosing. The generated configuration gets attached here, which is why
  # the file Terraform produces starts with exactly this address.
  to = aws_security_group.mysg

  # The ID of the real resource already running in AWS, copied from the security group
  # page in the EC2 console.
  id = "sg-07f13feb262ba8b6f"
}

# Then:
#   terraform plan -generate-config-out=mysg.tf
#
# This writes mysg.tf containing the full aws_security_group block, with ingress and
# egress rules reverse engineered from what actually exists in AWS. plan alone does not
# create the state file, so at this point nothing is being managed yet.
#
#   terraform apply -auto-approve
#
# This is the step that creates state and completes the import. Output reports one
# resource imported.
#
# After that, editing mysg.tf and applying again changes the real security group, which
# is the proof that the import took. In the video the port 80 rule was changed from
# 0.0.0.0/0 to 10.77.0.0/16 and the console reflected it after the apply.