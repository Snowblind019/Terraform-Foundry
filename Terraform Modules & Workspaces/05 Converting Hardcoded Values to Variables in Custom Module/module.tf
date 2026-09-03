# teams/A/module.tf
#
# The calling code. The provider block that was here for ap-south-1 was
# removed, since the region is now passed into the module and the provider
# inside the module reads it from var.region.

module "ec2" {
  source = "../../modules/ec2"

  # The three values the module requires. These are what plan reports back,
  # so changing instance_type to t2.large here and running plan again is
  # how the override was confirmed in the video.
  instance_type = "t2.large"

  # A made up AMI. It only needs to appear in the plan output, nothing is
  # being applied.
  ami = "ami-123"

  region = "ap-south-1"
}