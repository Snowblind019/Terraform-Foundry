# 44 prevent_destroy

The lifecycle argument that blocks a resource from being destroyed, and the one gap it does not cover.

Files in this folder:

- `prevent-destroy.tf`

Docs:

- https://developer.hashicorp.com/terraform/language/meta-arguments/lifecycle

---

## What it does

Set it on a resource and Terraform will refuse to destroy that resource. Running `terraform destroy` errors out instead of going through.

```hcl
lifecycle {
  prevent_destroy = true
}
```

## The practical

Instance already applied and running, tagged HelloEarth.

Ran `terraform destroy` first without the lifecycle block. Normal behaviour, it planned one resource to destroy and asked for confirmation. Answered no.

Added the lifecycle block with `prevent_destroy = true` and ran `terraform destroy` again. This time it errored straight away, saying the instance cannot be destroyed because it has `prevent_destroy` set. No confirmation prompt, it does not get that far.

## Why it exists

Safety against something expensive or painful being wiped by accident. Databases are the example given. Infrastructure often is not run by hand, it goes through scripts or Jenkins, and in that setup nobody is sitting there to catch a destroy before it runs.

## The gap

The protection only applies while the argument is in the configuration. Remove the resource block entirely and Terraform has nothing left telling it the resource is protected.

Tested it. Deleted the whole resource block and ran `terraform apply`. Terraform saw a resource in state that is no longer in the configuration, and planned to destroy it. `prevent_destroy` went out of the file along with the block, so there was nothing to stop it.

So this protects against a destroy command, not against someone deleting the code.