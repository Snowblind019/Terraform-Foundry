provider "aws" {
  region = "us-west-2"

  # Placeholders. Terraform picks up credentials from the AWS CLI config and
  # environment variables on its own, so these two lines are not needed.
  access_key = "YOUR-KEY"
  secret_key = "YOUR-KEY"
}

resource "aws_instance" "myec2" {
  ami = "ami-082b5a644766e0e6f"

  # Pulling one value out of the list by index. Index starts at 0, so [1] is
  # the second entry, m5.xlarge. Changing the number here changes the instance
  # type without touching the variable itself.
  instance_type = var.list[1]
}

# A list holds multiple values in order. Nothing here restricts the instance to
# one of them, the list is just the set of options sitting in the variable.
#
#   var.list[0] = m5.large
#   var.list[1] = m5.xlarge
#   var.list[2] = t2.medium
#
# Going past the end, var.list[3], fails at plan time.
variable "list" {
  type    = list
  default = ["m5.large", "m5.xlarge", "t2.medium"]
}

# A map is key and value pairs instead of an ordered list. Keys are regions and
# values are instance types, so this is a lookup table of which instance type to
# use where. Referenced by key rather than position:
#
#   var.types["us-west-2"] = t2.nano
#
# Declared here but not used by the instance above, which is still on the list.
variable "types" {
  type = map
  default = {
    us-east-1  = "t2.micro"
    us-west-2  = "t2.nano"
    ap-south-1 = "t2.small"
  }
}

# Note on both variables: type = list and type = map are the bare old forms.
# Current Terraform wants the element type as well, list(string) and
# map(string). The bare forms still work, they just warn on plan.