# Two resources plus a remote backend. The resources exist so there is something in
# state to list, show, move, and remove. The backend is S3 so that terraform state pull
# has a remote to pull from, which is the whole reason pull exists as a command.

terraform {
  backend "s3" {
    # CHANGE THIS. S3 bucket names are unique across every AWS account. Create your own
    # bucket in the console first and paste its name here.
    bucket = "kplabs-terraform-backends"

    key    = "demo.tfstate"
    region = "us-east-1"
  }
}

# The resource that survives the whole lab. Renamed from dev to prod during the
# terraform state mv section.
resource "aws_iam_user" "dev" {
  name = "kplabs-user-01"
}

# After the state mv section this becomes:
# resource "aws_iam_user" "prod" {
#   name = "kplabs-user-01"
# }
#
# Change the config only AFTER running:
#   terraform state mv aws_iam_user.dev aws_iam_user.prod
# Changing the name in config alone makes terraform plan show a destroy and a recreate,
# because the new local name reads as a different resource.

resource "aws_security_group" "prod" {
  name = "terraform-firewalls"
}

# --- Added partway through, for the terraform state rm demonstration ---
#
# These two blocks were not in the starting file. They were added so the security group
# had rules that could be modified by hand in the console, producing drift.
#
# Both are removed from state and then from the config by the end of the lab:
#   terraform state rm aws_vpc_security_group_ingress_rule.example
#   terraform state rm aws_vpc_security_group_ingress_rule.example2
#   terraform state rm aws_security_group.prod
# then delete the blocks. Order matters. Deleting the blocks first makes Terraform
# destroy the real resources in AWS.
#
# Docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule

resource "aws_vpc_security_group_ingress_rule" "example" {
  # Points at the security group above rather than a hardcoded ID.
  security_group_id = aws_security_group.prod.id

  cidr_ipv4   = "10.0.0.0/8"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_vpc_security_group_ingress_rule" "example2" {
  security_group_id = aws_security_group.prod.id

  cidr_ipv4   = "10.0.0.0/8"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

# The drift step: after applying, one of these rules was edited by hand in the AWS
# console, changing 10.0.0.0/8 to 0.0.0.0/0 and adding a description. terraform plan
# then wanted to revert it. That is the situation state rm is for, once the manual
# edits have piled up far enough that reconciling them is not worth it.