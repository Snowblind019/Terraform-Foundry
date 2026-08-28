# Three resources in one file. A plain terraform plan reports 3 to add,
# because Terraform works against the merged configuration, not a single
# resource.
resource "aws_iam_user" "this" {
  name = "test-aws-user"
}

resource "aws_security_group" "allow_tls" {
  name = "terraform-firewall"
}

resource "local_file" "foo" {
  content  = "foo!"
  filename = "${path.module}/foo.txt"
}

# To act on just the local file, pass its resource address to -target. Works
# on plan, apply and destroy alike, and the other two resources are untouched:
#
#   terraform plan -target local_file.foo
#   terraform apply -target local_file.foo
#   terraform destroy -target local_file.foo
#
# The quoted form does the same thing, and one or the other can fail depending
# on the shell:
#
#   terraform plan -target="local_file.foo"
#
# Terraform prints a warning that targeting is in effect. Not for routine use.