# teams/A/module.tf
#
# Calling the EC2 module that lives elsewhere on the same workstation.
# Because both sit on the local file system, the local path source type
# is the one to use, and a local path has to start with ./ or ../

module "ec2" {
  # Read this as directory navigation from teams/A:
  #   ../        back to teams
  #   ../../     back to kplabs-terraform-modules
  #   modules/   into the modules folder
  #   ec2        into the module itself
  #
  # Nothing else is set here. The AMI, instance type and region all come
  # from main.tf inside the module.
  source = "../../modules/ec2"
}