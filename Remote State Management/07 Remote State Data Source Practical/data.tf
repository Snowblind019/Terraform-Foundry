# Security team side, step one: declare where the other team's state lives.
#
# Copied from the remote state data source documentation, which does not default to S3,
# so the backend argument and the config block both had to be changed.

data "terraform_remote_state" "vpc" {
  # Which backend type the networking team used. Changed from the documentation default.
  backend = "s3"

  # These three values are copied straight out of the networking team's backend.tf.
  # They have to match, or this points at nothing.
  config = {
    bucket = "kplabs-networking-bucket-demo"
    key    = "eip.tfstate"
    region = "us-east-1"
  }
}

# The local name here, vpc, is what gets used in the reference over in sg.tf:
#   data.terraform_remote_state.vpc.outputs.eip_addr
#
# Nothing in this file says which value to read. It only establishes the connection to
# the state file. Picking a specific output happens at the point of use.
#
# Docs: https://developer.hashicorp.com/terraform/language/state/remote-state-data