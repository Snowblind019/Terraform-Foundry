# Simple local file so the lab is about the plan file, not the resource.
resource "local_file" "foo" {
  content  = "Hello World"
  filename = "terraform.txt"
}

# Workflow:
#
#   terraform plan -out=infra.plan
#   terraform apply infra.plan
#
# Applying from a saved plan ignores any edits made to this file after the
# plan was written. Changing the filename to terraform2.txt and the content to
# NEW CONTENT, then applying infra.plan, still produced terraform.txt with
# Hello World.
#
# Reading the saved plan, which is a binary file:
#
#   terraform show infra.plan
#   terraform show -json infra.plan
#   terraform show -json infra.plan | jq