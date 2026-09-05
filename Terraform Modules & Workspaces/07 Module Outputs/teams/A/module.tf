# teams/A/module.tf
#
# The root module. Calls the EC2 module and creates an Elastic IP that has
# to end up attached to the instance the module made.

provider "aws" {
  region = "us-east-1"
}

module "ec2" {
  source = "../../modules/ec2"
}

resource "aws_eip" "this" {
  domain = "vpc"

  # The instance argument is the equivalent of clicking Associate in the
  # console. Left off, the EIP still gets created but sits unattached,
  # which is no use and still gets charged for.
  #
  # The reference format is module.<module name>.<output name>, so it is
  # instance_id here, the name of the output block, not id, the name of the
  # attribute inside the module. Using module.ec2.id fails validation.
  instance = module.ec2.instance_id
}