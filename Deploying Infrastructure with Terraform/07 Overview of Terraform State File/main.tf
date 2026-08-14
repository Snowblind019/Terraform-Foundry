provider "aws" {
  region = "us-west-2"
}

# Nothing special about this resource. The point of the section is what happens
# in terraform.tfstate once it's applied, not the instance itself.
#
# Sequence worth running once:
#   terraform apply                      -> terraform.tfstate appears
#   grep -o 'i-[0-9a-f]*' terraform.tfstate   -> the real instance ID is in there
#   mv terraform.tfstate terraform.tfstate.old
#   terraform plan                       -> now wants to CREATE, not modify
#   mv terraform.tfstate.old terraform.tfstate
#   terraform plan                       -> finds it again by ID
#
# Change instance_type below and re-plan to see it target the existing instance
# by ID rather than proposing a new one. That mapping only exists because of
# the state file.
resource "aws_instance" "WinterdayEC2" {
  ami           = "ami-091124c3965bce679"
  instance_type = "t3.micro"

  tags = {
    Name = "WinterdayEC2"
  }
}

# Reminder: terraform destroy empties the state file but does not delete it.
# You're left with terraform.tfstate holding an empty resources array, plus
# terraform.tfstate.backup holding the previous version. That backup is one
# revision deep, not a backup strategy.
