# The map that makes the code workspace aware. The keys are workspace
# names, so there is one entry for each workspace that exists, including
# default.
locals {
  instance_type = {
    default = "t2.nano"
    dev     = "t2.micro"
    prod    = "m5.large"
  }
}

resource "aws_instance" "myec2" {
  # AMI for North Virginia. Change it if using another region.
  ami = "ami-08a0d1e16fc3f61ea"

  # terraform.workspace returns the name of the workspace currently
  # selected. That name is used as the key into the map above, so selecting
  # prod gives m5.large, dev gives t2.micro, and default gives t2.nano.
  #
  # A workspace name with no matching key in the map would have nothing to
  # look up.
  instance_type = local.instance_type[terraform.workspace]
}

# Base version before the map was added. Every workspace planned the same
# t2.micro instance, which is what made the change necessary.
#
# resource "aws_instance" "myec2" {
#   ami           = "ami-08a0d1e16fc3f61ea"
#   instance_type = "t2.micro"
# }