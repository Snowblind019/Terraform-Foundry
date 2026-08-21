provider "aws" {
  region = "us-west-2"

  # The video hardcodes the keys here to keep the demo simple. Placeholders
  # only, never put real keys in a .tf file.
  access_key = "my-access-key"
  secret_key = "my-secret-key"
}

# Normally this belongs in variables.tf. Terraform loads every .tf file in the
# folder so it works fine here, it is just not how it should be organized.
variable "instance_type" {}

resource "aws_instance" "myec2" {
  # This AMI is an ap-south-1 image while the provider above is us-west-2, so
  # this will fail on apply. Swap in a us-west-2 AMI or change the region.
  ami           = "ami-0e670eb768a5fc3d4"
  instance_type = var.instance_type
}
