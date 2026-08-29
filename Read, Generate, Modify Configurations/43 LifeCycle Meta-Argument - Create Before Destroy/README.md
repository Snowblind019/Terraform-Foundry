# 43 create_before_destroy

The lifecycle argument that flips the order of a replacement, so the new object is built before the old one is torn down.

Files in this folder:

- `create-before-destroy.tf`

Docs:

- https://developer.hashicorp.com/terraform/language/meta-arguments/lifecycle

---

## The default order

When an argument changes and the provider cannot update it in place, Terraform replaces the resource. By default that means destroy first, then create.

The example again is the AMI on an EC2 instance. Change it from Linux to Windows and AWS will not let you swap it on the running instance, so the whole thing has to be built new. Terraform terminates the running instance, waits for it to go, then launches the replacement.

The problem with that in production is the gap. There is a window where the old instance is gone and the new one does not exist yet.

## Watching the default

Started with the instance already applied and running, on the Amazon Linux AMI.

Changed the AMI ID to an Ubuntu one and ran `terraform plan`. Came back with 1 to add, 1 to destroy, which is the replacement.

`terraform apply -auto-approve` and the output order was clear. Destruction first. It waited for the old instance to finish terminating, and only then started creating the new one.

## The argument

```hcl
lifecycle {
  create_before_destroy = true
}
```

With this set, the replacement object gets created first and the old one is destroyed after the new one exists.

## Watching it with the flag on

Put the AMI back to the Amazon Linux one and added the lifecycle block at the same time.

`terraform plan` looked the same as before, 1 to add and 1 to destroy. The plan does not change, only the order it happens in.

`terraform apply -auto-approve` and this time creation came first. Once the new instance was up, Terraform moved on to terminating the old one.

## Cleanup

Both apply runs in this lab leave a running EC2 instance behind. Destroy it when done.