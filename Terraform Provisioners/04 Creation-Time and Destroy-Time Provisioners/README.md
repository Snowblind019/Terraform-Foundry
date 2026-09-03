# 04 Creation-Time and Destroy-Time Provisioners

Provisioners can be tied to either end of a resource lifecycle. This also covers what happens when a provisioner fails.

Files in this folder:

- `creation-destroy-provisioner.tf`

---

## Creation-time provisioners

This is the default. Any provisioner defined in a resource block without extra configuration runs after the resource is created. Every provisioner in the earlier labs was a creation-time provisioner.

These only run at creation. They do not run on updates or any other part of the resource lifecycle. If an EC2 instance is created with a provisioner attached, the provisioner runs on that first apply. Changing the instance later, for example moving it from one size to another, does not fire it again.

## Destroy-time provisioners

These run before the resource is destroyed. The only change is adding `when = destroy` to the block:

```sh
provisioner "local-exec" {
  when    = destroy
  command = "echo This is a destroy-time provisioner"
}
```

On `terraform destroy`, the provisioner runs first and the resource is removed afterwards.

A real use case for this is de-linking software before the machine goes away. Production instances are often registered with a central antivirus dashboard, and when an instance is terminated you want it de-linked from that dashboard rather than left sitting there as a stale entry. A destroy-time provisioner can do that de-linking before termination.

## Running both

The demo file creates an IAM user with one provisioner of each type.

```sh
terraform apply -auto-approve
```

The user is created and only the creation-time provisioner runs, printing its echo output.

```sh
terraform destroy -auto-approve
```

The user is deleted and only the destroy-time provisioner runs, printing its echo output.

## A failed provisioner taints the resource

If a creation-time provisioner fails for any reason, the resource is marked as tainted. The reason for that is a failed provisioner can leave a resource in a semi configured state.

Think of a remote-exec provisioner installing software on an EC2 instance. If the install fails, whether from a connectivity problem, a permissions problem, or anything else, the instance exists but the configuration step that made it useful never completed. The instance is only half set up, so Terraform will not treat it as good.

A tainted resource is planned for destruction and recreation on the next `terraform apply`.

## Reproducing it

Break the creation-time command so it is not a valid command on the local system, for example by removing the `echo` and leaving the bare text behind.

```sh
terraform apply -auto-approve
```

The IAM user is created, then the local-exec provisioner runs and fails with an error saying the command is not recognized. Checking the AWS console confirms the user does exist.

Opening `terraform.tfstate` and looking at the `aws_iam_user` entry shows its status as tainted.

Running `terraform apply` again produces a plan that destroys and recreates that resource. Answering no to the prompt leaves it as it is.

This applies to whichever resource the failing provisioner was attached to.