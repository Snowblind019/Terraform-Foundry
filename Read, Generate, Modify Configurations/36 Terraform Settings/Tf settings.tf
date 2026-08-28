terraform {
  # Exact match, no operator, so only this version of Terraform can run this
  # configuration. Anything else fails plan with "Unsupported Terraform Core
  # version". This is the version from the video, check terraform version and
  # set it to whatever is installed locally before running.
  required_version = "1.9.1"

  required_providers {
    aws = {
      # source is the registry address, version is the constraint.
      # Exact pin again. The docs example uses >= 2.7.0, which would allow
      # that version or anything newer.
      #
      # After changing this, plan fails with "inconsistent dependency lock
      # file" because the lock still holds whatever init downloaded first.
      # Fix with the command the error prints:
      #
      #   terraform init -upgrade
      version = "5.54.1"
      source  = "hashicorp/aws"
    }
  }
}

resource "aws_security_group" "sg_01" {
  name = "app_firewall"
}