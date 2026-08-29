# 45 ignore_changes

Telling Terraform to leave certain attributes alone, either a named list of them or everything.

Files in this folder:

- `ignore-changes.tf`

Docs:

- https://developer.hashicorp.com/terraform/language/meta-arguments/lifecycle

---

## The problem

Infrastructure gets changed outside Terraform. Sometimes by another automated tool, sometimes by hand. Terraform sees the drift on the next plan and tries to pull the resource back to what the configuration says.

Where the outside change was made on purpose and should stay, `ignore_changes` under the lifecycle block is how you tell Terraform not to touch that attribute.

An EC2 instance has hundreds of attributes. This is not all or nothing, you name the specific ones you want left alone.

## Default behaviour first

Instance already applied, one tag, `Name = HelloEarth`.

Added a random extra tag by hand in the console, then ran `terraform plan`. Terraform picked up the extra tag and planned to set it to null. Applied with `-auto-approve` and the tag was gone from the instance, back to just the one.

## Ignoring tags

```hcl
lifecycle {
  ignore_changes = [tags]
}
```

Added the extra tag by hand again and ran `terraform plan`. No changes. The manual tag stayed put.

## Adding a second attribute

Tags are not the only thing you can list. Tried `instance_type` next.

Stopped the instance in the console, changed the instance type from `t2.micro` to `t1.micro`, applied the change on the AWS side.

`terraform plan` at that point ignored the tags as expected, but picked up the instance type and planned to change it from `t1.micro` back to `t2.micro`. One change.

Added it to the list:

```hcl
ignore_changes = [tags, instance_type]
```

Plan again, no changes.

## The all keyword

If a lot of attributes get changed outside Terraform, listing every one of them gets impractical. There is a keyword for that:

```hcl
ignore_changes = all
```

Plan came back with no changes, same as the list version.

## What all actually costs you

With `all` set, Terraform will still create and destroy the object, but it will never propose an update to it.

That includes changes you make in the configuration yourself, not just drift from outside. Tested it by editing the tag in the tf file from `HelloEarth` to `HelloWorld` and running plan. No changes, infrastructure matches configuration. Terraform ignored an edit that was sitting right there in the file.

So `all` is not "ignore manual changes". It is "ignore updates entirely", from either direction.