# teams/A/module.tf
#
# The region moved out here. The module no longer configures a provider or
# takes a region variable, so the calling code sets it instead.

provider "aws" {
  region = "ap-south-1"
}

module "ec2" {
  source = "../../modules/ec2"

  # Only the two arguments the module still declares. Passing region here
  # would now fail, since that variable was removed from the module.
  instance_type = "t2.large"
  ami           = "ami-123"
}