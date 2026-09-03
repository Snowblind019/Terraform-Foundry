# The whole lab is this one block. No aws_instance resource, no
# aws_security_group resource, no rules. The module supplies all of it.
#
# The block was copied from the Provision Instructions panel on the
# module's registry page, then subnet_id was added after the first plan
# failed.

module "ec2-instance" {
  # The module path, same as the registry URL:
  # registry.terraform.io/modules/terraform-aws-modules/ec2-instance/aws
  source = "terraform-aws-modules/ec2-instance/aws"

  # A module can have several published versions, so this pins the one
  # being used.
  version = "6.1.4"

  # Change this to a subnet in my own account.
  #
  # Without it, terraform plan fails because more than one subnet matched
  # and the module cannot pick between them. The ID came from VPC in the
  # console, under the subnets attached to the default VPC. Whichever
  # subnet goes here is the one the instance launches into.
  #
  # This is a requirement of this module at this version. Other modules
  # can be written to work out the VPC and subnet on their own.
  subnet_id = "subnet-03f8c90a72ead2e4d"
}