provider "aws" {
  region = "us-west-2"
}

resource "aws_instance" "WinterdayEC2" {
  ami           = "ami-091124c3965bce679"
  instance_type = "t3.micro"

  tags = {
    Name = "WinterdayEC2"
  }
}

# The failure worth running once, in a scratch folder, on a throwaway instance:
#
#   terraform apply -auto-approve      # instance exists, state is populated
#   [change region above to us-east-1]
#   terraform plan                     # wants to CREATE. state on disk untouched.
#   [change region back]
#   terraform plan                     # finds it again, no changes. no harm done.
#
#   [change region to us-east-1 again]
#   terraform refresh                  # no plan, no prompt, writes immediately
#   cat terraform.tfstate              # empty. resource is gone from state.
#
# The instance is still running in the original region, still billing, now with
# nothing tracking it. Recover with:
#   cp terraform.tfstate.backup terraform.tfstate
# but that backup is one revision deep, so a second refresh before you notice
# overwrites the good copy.
#
# Refresh can't distinguish "deleted" from "I can't see it". Wrong region, wrong
# AWS_PROFILE, wrong account, expired SSO session, revoked Describe* permissions
# all look identical from where Terraform is standing.
#
# Use these instead. Both show a plan and wait for confirmation:
#   terraform plan -refresh-only
#   terraform apply -refresh-only