# Creation-time and destroy-time provisioner lab.
#
# A provisioner with no "when" argument is a creation-time provisioner.
# It runs after the resource is created, and only then. Updates to the
# resource later do not fire it again.
#
# Adding "when = destroy" makes it a destroy-time provisioner, which runs
# before the resource is destroyed.
#
# If a creation-time provisioner fails, the resource is marked tainted and
# gets destroyed and recreated on the next apply, because a failed
# provisioner can leave the resource semi configured.

resource "aws_iam_user" "lb" {
  name = "demoiamuser"

  # Runs on terraform apply, after the user is created.
  provisioner "local-exec" {
    command = "echo This is a creation-time provisioner"
  }

  # Runs on terraform destroy, before the user is deleted.
  provisioner "local-exec" {
    when    = destroy
    command = "echo This is a destroy-time provisioner"
  }
}