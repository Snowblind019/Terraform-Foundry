# 56 Moved Blocks

Renaming a resource's local name makes Terraform destroy and recreate it. A `moved` block tells Terraform the object at the old address is the same object as the one at the new address.

Files in this folder:

- `moved.tf`

Docs:

- https://developer.hashicorp.com/terraform/language/modules/develop/refactoring

---

## The problem

Long lived configurations end up needing objects renamed or moved. Say a security group was created years ago with the local name `database_firewall`, and now there is a naming standard to follow, so it should be `payment_database_firewall`.

Renaming it in the config is not as simple as it looks. Terraform reads a changed resource address as an instruction to destroy the resource at the old address and create one at the new address. The plan after the rename shows `database_firewall` being destroyed and `payment_database_firewall` being created.

A rename triggering a full recreation is not something you want in production.

## Walking through it

```hcl
resource "aws_security_group" "database_firewall" {
  name = "db_firewall"
}
```

`terraform apply -auto-approve` creates it, and the `db_firewall` security group shows up in the AWS console.

Renaming the local name to `payment_database_firewall` and running `terraform plan` shows the destroy and recreate.

## The moved block

```hcl
moved {
  from = aws_security_group.database_firewall
  to   = aws_security_group.payment_database_firewall
}
```

Two arguments. `from` is the old resource address, `to` is the new one. With that in place, Terraform treats the existing object at the old address as if it belongs to the new address, and stops trying to recreate anything.

## What the plan shows after

Running plan with the moved block, nothing is being added, changed or destroyed. There is still one operation though, and it is a state file update.

The reason is that the state file still holds the old name. The config was renamed and the moved block was added, but `terraform.tfstate` has not caught up yet. That pending operation is the rename being written into state.

`terraform apply -auto-approve` completes, and the state file now shows `payment_database_firewall` instead of `database_firewall`. Running plan again after that returns no changes.

## Two ways to do this

Renaming without recreation can be done either way:

- `terraform state mv`, run from the CLI
- a `moved` block in the configuration

The moved block's advantage is visibility. It lives in the config, so the whole team can see it in the code and in version control. A `state mv` runs in someone's terminal and leaves no trace in the configuration, so nobody else necessarily knows it happened.

`terraform state mv` has its own advantage: it can be scripted. Bash, Python, whatever the automation is, the command can be called from it, which suits bulk operations against the state file.

## Commands used

```sh
terraform plan

terraform apply -auto-approve
```