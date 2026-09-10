# multi-provider-config.tf
#
# Section 6, video 1: multiple provider configuration using the alias meta argument.
#
# -----------------------------------------------------------------------------
# BASE STATE (what the file looked like at the start of the video)
#
# provider "aws" {
#   region = "ap-southeast-1"
# }
#
# resource "aws_security_group" "allow_tls" {
#   name     = "prod_firewall"
#   provider = aws.usa
# }
#
# resource "aws_security_group" "allow_tls" {
#   name     = "staging_firewall"
#   provider = aws.mumbai
# }
#
# Two problems with the base state:
#   1. Both resources use the same local name "allow_tls", so terraform validate
#      fails with: Duplicate resource "aws_security_group" configuration.
#      Fixed by renaming to sg_1 and sg_2.
#   2. The provider arguments reference aws.usa and aws.mumbai, but neither alias
#      exists yet. Those provider blocks get added below.
# -----------------------------------------------------------------------------


# The default provider. No alias, so any resource in this file that does not
# name a provider is created here. In the video this is Singapore, and it is
# where both security groups ended up until the resources were wired to the
# aliased providers further down.
provider "aws" {
    region = "ap-southeast-1"
}

# Second AWS provider block. Adding a second block of the same provider type is
# rejected outright (Duplicate provider configuration) unless it carries an
# alias, which is exactly the error the video triggers on purpose before adding
# this line. The alias name is arbitrary; it just has to be unique.
provider "aws" {
    alias  = "mumbai"
    region = "ap-south-1"
}

# Third AWS provider block, same rule. us-east-1 is Virginia.
provider "aws" {
    alias  = "usa"
    region = "us-east-1"
}

# Defining the aliases above is only half of it. Without the provider argument
# on the resource, Terraform falls back to the default block and creates
# everything in ap-southeast-1, which the video demonstrates with an apply
# before adding these lines.
#
# The reference format is the provider type, a dot, then the alias name.
resource "aws_security_group" "sg_1" {
  name        = "prod_firewall"
  provider    = aws.usa
}

resource "aws_security_group" "sg_2" {
  name        = "staging_firewall"
  provider    = aws.mumbai
}