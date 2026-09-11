# demo.tf
#
# Section 6, video 5: dependency lock file.
#
# This is the end state of the file. The video starts with a version range in the
# block below (the screenshot shows a constraint that allows 4.2, 4.4, 4.6 and so
# on), runs terraform init, and Terraform resolves it to 4.62.0 and writes that
# exact version into .terraform.lock.hcl.
#
# The 4.60 below is the edit made afterwards, standing in for "4.62.0 has a
# problem and I want to go back". Because 4.60 does not match what the lock file
# recorded, a plain terraform init fails at this point. terraform init -upgrade is
# what gets 4.60 installed and the lock file updated.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.60"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}



resource "aws_instance" "web" {
  # WARNING: ami-123 is unquoted in the pasted code, so this file will not parse
  # as given. It needs to be a quoted string, and a real AMI ID for the region.
  # Left as pasted rather than silently corrected.
  ami           = ami-123
  instance_type = "t2.micro"
}