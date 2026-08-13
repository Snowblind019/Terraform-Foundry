# Terraform assumes the "hashicorp" namespace unless you tell it otherwise, so
# anything published by someone else has to be declared here with its full
# namespace/name source. Without this block, `provider "digitalocean" {}` sends
# init looking for hashicorp/digitalocean, which doesn't exist, and it fails.
#
# I'm pinning AWS here too. Not required since it resolves under hashicorp by
# default, but pinning the major version means a future init can't drag in a
# breaking release.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0" # ~> 2.0 means any 2.x, never 3.0
    }
  }
}

# The label on a provider block is only ever the short local name. The
# namespace/name path goes in required_providers above, not down here.
provider "aws" {}

resource "aws_instance" "SnowydayEC2" {
  ami           = "ami-091124c3965bce679"
  instance_type = "t3.micro"

  tags = {
    Name = "SnowydayEC2"
  }
}
