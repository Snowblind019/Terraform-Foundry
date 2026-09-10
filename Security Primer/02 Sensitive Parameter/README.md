# 02 - Sensitive Parameter

Section 6: Security Primer

## What this video covers

How Terraform exposes attribute values in plain text in CLI output and logs, and how the
`sensitive` parameter, sensitive-specific resource types, and provider built-in logic keep
those values out of the output.

## The problem

Running `terraform plan` or `terraform apply` prints the values of the attributes on every
resource in the configuration. If one of those attributes is a password, it goes to the
terminal in plain text, and it can end up in logs as well.

The starting example is a `local_file` resource that writes `supersecretpassw0rd` into
`password.txt`. `terraform plan` shows both the filename and the content.

## Walkthrough

### Step 1: the baseline

```
resource "local_file" "foo" {
  content  = "supersecretpassw0rd"
  filename = "password.txt"
}
```

`terraform init`, then `terraform plan`. The content is visible in the plan output exactly as
written.

### Step 2: moving the value into a variable does not help

The instinct is to pull the password out of the resource block and into a variable, on the
assumption that because the literal string no longer appears next to `content`, it will not
show up in the plan.

```
variable "password" {
  default = "supersecretpassw0rd"
}

resource "local_file" "foo" {
  content  = var.password
  filename = "password.txt"
}
```

That is not how it works. `terraform plan` computes `var.password` and prints the resolved
value. The password is still visible in the content attribute.

### Step 3: sensitive = true on the variable

```
variable "password" {
  default   = "supersecretpassw0rd"
  sensitive = "true"
}
```

`terraform plan` now shows the content attribute as `(sensitive value)` instead of the
password.

### Step 4: sensitive-specific resource types

For resource types where sensitive values are common, HashiCorp often provides a separate
resource that handles this without needing `sensitive = true` anywhere. The local provider
has `local_sensitive_file` alongside `local_file`.

```
resource "local_sensitive_file" "foo" {
  content  = "supersecretpassw0rd"
  filename = "password.txt"
}
```

The only change is the resource type. The variable was dropped and the password put back
inline. `terraform plan` still shows the content as a sensitive value.

The `local_file` documentation carries a note pointing at `local_sensitive_file` when the
file content is sensitive. This pattern is not available for every resource type, so the
provider documentation is the thing to check.

### Step 5: referencing a sensitive value in an output

```
output "pass" {
  value = local_sensitive_file.foo.content
}
```

`terraform plan` fails. The plan itself still marks the content as a sensitive value, but the
operation errors out because the output block would put that sensitive value on the CLI.

### Step 6: sensitive = true on the output block

```
output "pass" {
  value     = local_sensitive_file.foo.content
  sensitive = true
}
```

The error goes away. `terraform apply` completes, and the outputs section shows
`pass = <sensitive>` rather than the password. The `password.txt` file on disk contains the
real value as expected.

## Why define the output at all

The reason to keep an output block for a value you are deliberately hiding from the CLI is
the state file. Opening `terraform.tfstate` after the apply shows an `outputs` section
holding `supersecretpassw0rd` in plain text.

Other Terraform projects, run by other teams, read the state file to pull values out of that
outputs section. So the output block is what makes the value available for that kind of
cross-project consumption, while `sensitive = true` keeps it out of the terminal and the
logs.

## Important pointer

The `sensitive` parameter does not protect the state file and does not redact anything from
it. Values are visible there. Its scope is CLI output and logs only. Protecting the state
file itself is a separate topic, deferred to a later video.

## Provider built-in sensitivity

Mature providers already know which attributes are sensitive on certain resources and redact
them without being told. The AWS provider does this for RDS.

Using the basic usage example from the `aws_db_instance` documentation, with `username` and
`password` both written inline in plain text, `terraform plan` shows the username but marks
the password as a sensitive value. No `sensitive` parameter involved.

This is not applied to every resource, just the ones where it obviously matters.

If the username should be hidden too, that goes back to the variable approach:

```
variable "db_user" {
  default   = "admin"
  sensitive = true
}
```

with `username = var.db_user`. After that, `terraform plan` shows the username as a sensitive
value as well. Which values count as sensitive beyond the obvious ones is an
organization-by-organization decision.

## Documentation referenced

- https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file
- https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/sensitive_file
- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance