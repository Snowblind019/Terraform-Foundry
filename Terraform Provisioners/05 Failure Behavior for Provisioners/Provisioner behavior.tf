# Provisioner failure behavior lab.
#
# echo1 is not a real binary, so this command always fails. That is the
# point, it gives the provisioner something to fail on.
#
# By default a failing provisioner fails the whole terraform apply and the
# resource is marked tainted, so the next apply destroys and recreates it.
#
# on_failure controls that:
#   fail     raise the error and stop applying. This is the default, so
#            omitting on_failure behaves the same way. Resource is tainted.
#   continue ignore the error and carry on with creation or destruction.
#            Resource is not tainted.
#
# The error still shows in the output with continue, Terraform just does
# not stop for it.

resource "aws_iam_user" "lb" {
  name = "demo-provisioner-user"

  provisioner "local-exec" {
    command = "echo1 This is creation time provisioner"
    on_failure = continue
  }
}