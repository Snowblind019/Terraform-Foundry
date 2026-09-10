# Same throwaway security group as the earlier backend lab. It exists so there is
# something to apply and therefore something to write to state. The lab is about where
# the state file ends up, not about the resource.

resource "aws_security_group" "prod" {
  name = "production-sg"
}

# Run with:
#   terraform init
#   terraform apply -auto-approve
#
# terraform init is required first because a backend is declared. It initializes the
# backend before anything else happens.
#
# After the apply, check the project folder: there is no terraform.tfstate. Check the
# S3 bucket instead and production.tfstate is there.

# The backend block lives in backend.tf rather than here. Terraform would accept it in
# this file, but with 40 or 50 files in a project the filename is what tells you where
# the backend configuration is.