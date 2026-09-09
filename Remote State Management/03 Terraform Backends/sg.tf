# The resource here is incidental. It exists so there is something to apply, so the
# state file has content, and so the folder can be inspected before and after the
# backend block is added.

resource "aws_security_group" "prod" {
  name = "production-sg"
}

# Run without any backend block first:
#   terraform apply -auto-approve
#
# terraform.tfstate appears in this same folder. That is the default local backend
# doing its job. It is in use on every lab so far in the course, whether or not it
# was ever mentioned.
#
# Then, for the second half of the lab:
#   terraform destroy -auto-approve
#   (delete the old terraform.tfstate by hand)
#   (add the backend block, see backend.tf)
#   terraform init
#   terraform apply -auto-approve
#
# terraform init is required once a backend is explicitly declared.

# The instructor pasted the backend block into this file during the demo, then said
# it does not belong here in a real project. Terraform does not care which file it
# sits in, but resource definitions and backend configuration should be separated.
# It has been split out into backend.tf instead.
#
# terraform {
#   backend "local" {
#     path = "prod.tfstate"
#   }
# }