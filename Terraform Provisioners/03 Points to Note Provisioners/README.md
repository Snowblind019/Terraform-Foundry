# 03 Important Pointers for Provisioners

Two points to clear up confusion from the earlier demos. Provisioners are not tied to EC2 instances, and a single resource can hold more than one of them.

Files in this folder:

- `iam-provisioner.tf`

---

## Point 1: any resource type works

Every practical so far has attached the provisioner to `aws_instance`, which makes it look like provisioners only run when an EC2 instance is created. That is not the case. The rule is only that the provisioner is defined inside a resource block, it does not matter which resource.

This example attaches a local-exec provisioner to an IAM user:

```sh
resource "aws_iam_user" "lb" {
  name = "demoiamuser"

  provisioner "local-exec" {
    command = "echo local-exec provisioner is starting"
  }
}
```

When the IAM user is created, the provisioner runs after the resource creation takes place. The same applies to remote-exec if it were defined here.

Running it:

```sh
terraform apply -auto-approve
```

The output shows the IAM user being created, then the local-exec provisioner executing, and the echo output `local-exec provisioner is starting`.

## Point 2: multiple provisioners in one resource

A single resource block can hold as many provisioner blocks as needed. They can be all local-exec, all remote-exec, or a mix of both depending on the use case.

```sh
resource "aws_iam_user" "lb" {
  name = "demoiamuser"

  provisioner "local-exec" {
    command = "echo local-exec provisioner is starting"
  }

  provisioner "local-exec" {
    command = "echo local-exec provisioner is starting for 2nd time"
  }
}
```

Destroy the resource from the first run before applying this, since the provisioner only fires on creation:

```sh
terraform destroy -auto-approve
terraform apply -auto-approve
```

Both echo outputs appear in order, the first provisioner output followed by the second.