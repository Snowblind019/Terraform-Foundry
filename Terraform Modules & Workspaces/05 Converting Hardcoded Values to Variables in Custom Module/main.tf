# modules/ec2/main.tf
#
# The module code with the hardcoded values replaced by variables. Nothing
# in here decides what the instance actually looks like any more, all three
# values arrive from whoever calls the module.

provider "aws" {
  region = var.region
}

resource "aws_instance" "myec2" {
  ami           = var.ami
  instance_type = var.instance_type
}

# The declarations. Referencing var.ami is not enough on its own, the
# variable has to be declared as well, and VS Code flags the reference in
# red until it is.
#
# No defaults and no types are set, so all three are required. Leaving any
# of them out of the calling code makes terraform plan fail with "missing
# required arguments".
#
# These are being kept in main.tf to keep the lab simple. A separate
# variables file is the recommended place for them.
variable "ami" {}
variable "instance_type" {}
variable "region" {}