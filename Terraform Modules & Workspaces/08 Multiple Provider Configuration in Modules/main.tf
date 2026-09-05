# Root module.
#
# Two instances of the AWS provider. The one without an alias is the
# default and gets inherited by child module resources automatically. The
# aliased one does not, which is the whole point of this lab.

provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "mumbai"
  region = "ap-south-1"
}

module "sg" {
  source = "./modules/network"

  # Step 1 of 3. Aliased provider configurations are never inherited, so
  # this passes it in explicitly.
  #
  # Read it as: the root's aws.mumbai goes into the child module under the
  # name aws.prod. The left side is what the module calls it, the right
  # side is what it is here.
  #
  # This is a map rather than a single string because a module can use
  # resources from several providers, so more than one pair can be passed.
  providers = {
    aws.prod = aws.mumbai
  }
}