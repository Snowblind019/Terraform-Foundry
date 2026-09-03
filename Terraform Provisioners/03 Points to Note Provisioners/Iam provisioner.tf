# Provisioner pointers lab.
#
# Point 1: the resource here is an IAM user, not an EC2 instance.
# Provisioners are not tied to aws_instance, they just have to sit inside
# some resource block. The provisioner runs after that resource is created.
#
# Point 2: a single resource can hold multiple provisioner blocks. They can
# be all local-exec, all remote-exec, or a mix. These two run in order.

resource "aws_iam_user" "lb" {
  name = "demoiamuser"

  provisioner "local-exec" {
    command = "echo local-exec provisioner is starting"
  }

  provisioner "local-exec" {
    command = "echo local-exec provisioner is starting for 2nd time"
  }
}