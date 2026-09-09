# The config in this video is deliberately minimal. The point is not the security
# group itself, it is that this file plus variables.tf plus terraform.tfvars plus the
# state file all sat in one folder on one laptop, which is the situation the video is
# arguing against.

resource "aws_security_group" "allow_tls" {
  name = var.sg_name

  # This description is the line the instructor edited in the Git demo. He changed it
  # from "Managed from Terraform" to "Managed from TF", committed it, and then opened
  # the commit history to show the before and after values and the user who made the
  # change. That diff is the whole reason for keeping Terraform code under version
  # control: when something breaks days later, the history tells you what moved.
  description = "Managed from Terraform"

  # Value after the demo edit:
  # description = "Managed from TF"
}

# Applied with:
#   terraform apply -auto-approve
#
# After the apply, terraform.tfstate exists alongside these files, and the .terraform
# folder holds the downloaded AWS provider plugin. Neither of those belongs in the Git
# repository. .terraform was over 800 MB with just the one provider, and any team member
# can rebuild it with terraform init after cloning.