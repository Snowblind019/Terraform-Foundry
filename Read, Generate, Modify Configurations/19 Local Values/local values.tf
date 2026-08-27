provider "aws" {
  region = "ap-south-1"
}

# First approach, a variable holding the shared tags. This works fine for
# static values and is the one to reach for by default, since it can be
# overridden from tfvars, environment variables or the CLI.
variable "tags" {
  type = map
  default = {
    Team = "security-team"
  }
}

# Second approach, a locals block. Same idea, one central place for values used
# in more than one resource, but this one can hold expressions. The CreationDate
# line is why the variable above could not be used: variable defaults cannot
# contain function calls, locals can.
# formatdate takes a format spec and a timestamp, so timestamp() runs first and
# formatdate reshapes what it returns.
locals {
  default = {
    Team         = "security-teams"
    CreationDate = "date-${formatdate("DDMMYYYY", timestamp())}"
  }
}

# The block is locals, plural. The reference is local, singular.
resource "aws_security_group" "sg_01" {
  name = "app_firewall"
  tags = local.default
}

resource "aws_security_group" "sg_02" {
  name = "db_firewall"
  tags = local.default
}