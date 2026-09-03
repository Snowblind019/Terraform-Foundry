# modules/ec2/main.tf
#
# The hardcoded provider "aws" block that used to be here has been removed.
# A module should not be pinning the provider configuration itself.
#
# required_providers replaces it. The point is version control over the
# plugin, module code can work with some provider versions and not others,
# so stating which ones means terraform init pulls a version the code is
# known to work against.

terraform {
  required_providers {
    # The key is the local name for the provider. The example block copied
    # from the docs uses "mycloud" here, and leaving it as mycloud produced
    # a plan warning that the aws provider was implicitly specified but
    # listed in required_providers as mycloud. It has to be aws.
    aws = {
      source = "hashicorp/aws"

      # The version the code was confirmed working against. .terraform.lock.hcl
      # showed 5.51 installed and the registry had 5.52.0 published, so >= 5.50
      # covers it. A more specific constraint works too if the requirement
      # calls for it.
      version = ">= 5.50"
    }
  }
}

resource "aws_instance" "myec2" {
  ami           = var.ami
  instance_type = var.instance_type
}

# var.region is gone. The provider block was the only thing using it, so
# removing the provider block from the module removes the need for it, both
# the declaration here and the argument in the calling code.
variable "ami" {}
variable "instance_type" {}