# We are running Null Provisioner.
// This is second type of comment.

/*
Line 1
Line 2
Line 3
*/

# The resource itself is not the point of this lab. It runs a local-exec
# provisioner that echoes a line into sample.txt on the machine running
# Terraform.
resource "null_resource" "demo_run" {

  provisioner "local-exec" {

    command = "echo Null Provisioner has completed > sample.txt"

  }
}

# Second resource, wrapped in a block comment. It stays in the file but
# terraform plan does not see it, so only demo_run above runs. Delete the /*
# and */ when you want this one back.
/*
resource "null_resource" "demo_run2" {

 provisioner "local-exec" {

   command = "echo Null Provisioner has completed > sample.txt"

  }
}
*/