# 06 - Ephemeral Values and Write-Only Arguments

Section 6: Security Primer

## What this video covers

Two related features: `ephemeral` blocks, which produce values Terraform never writes to state
or plan files, and write-only arguments, which let those values reach a resource without being
persisted either.

## The problem

Creating a database means supplying a password. The usual answer is `sensitive = true`, which
is where lab 02 left things. But `sensitive` only redacts the CLI output. The actual value is
still written to `terraform.tfstate` in plain text.

That makes the state file the thing that matters. If it leaks, whoever has it can read the API
keys, the database password, and everything else in there.

## Part 1: demonstrating the problem

The starting configuration has three blocks:

- a `random_password` resource generating a 16 character password
- an `aws_db_instance` using that password
- an output for the password with `sensitive = true`

```
terraform apply -auto-approve
```

The RDS instance took about five minutes and two seconds to create. In the CLI output,
`db_password` showed as a sensitive value, as expected.

Opening `terraform.tfstate` shows the plain text password in two places:

1. In the outputs section, first thing visible.
2. In the `random_password` resource itself, under `result`.

The second one matters more than the first. Even with no output block at all, just the
`random_password` resource and an apply, the generated password lands in state.

```
terraform destroy -auto-approve
```

## Part 2: ephemeral blocks

An ephemeral block defines a resource that is temporary. Ephemeral resources have their own
lifecycle, and Terraform does not store information about them in state or plan files.

The change is one word. `resource "random_password"` becomes `ephemeral "random_password"`,
and everything inside the block stays the same.

### Demo

With the `aws_db_instance` commented out and the password block switched to `ephemeral`:

```
terraform plan
```

Reports no changes to infrastructure.

```
terraform apply -auto-approve
```

Completes, and `terraform.tfstate` shows nothing.

Switching the block back to `resource` and applying again puts the generated password back in
the state file, visible in plain text.

The registry documents both forms. There is a `random_password` resource and, further down the
same page, an ephemeral `random_password`.

## Part 3: write-only arguments

Write-only arguments pass temporary values into Terraform-managed resources during the
operation, without persisting them to state or plan files.

So the ephemeral block generates the password, and the write-only argument on
`aws_db_instance` receives it. The value being read out of the ephemeral resource is not
persisted either.

The `aws_db_instance` documentation carries a note: the write-only argument `password_wo` is
available in place of `password`. Write-only arguments require Terraform 1.11.0 or later.

Both arguments exist on the resource. Using the plain `password` argument stores the value in
state, which is the whole thing being avoided, so `password_wo` is used instead. It is
optional in the documentation.

### An ephemeral value cannot go to an output

Before wiring it up, the video demonstrates what does not work. Pointing the output block at
`ephemeral.random_password.db_password.result`, keeping `sensitive = true`, and running
`terraform plan`:

```
This output value is not declared as returning an ephemeral value, so it cannot be set
to a result derived from an ephemeral value.
```

Terraform blocks it, and the reason is that it defeats the purpose. You generate an ephemeral
value and then write it to the state file through the output.

### Wiring it up

The output block was commented back out, `password` was replaced with `password_wo`, and the
value set to `ephemeral.random_password.db_password.result`.

`terraform plan` then failed on a missing required argument: `password_wo_version`. It is in
the documentation alongside `password_wo`. Added with a value of 1.

`terraform plan` now worked, but showed it was going to destroy the `random_password`
resource, because that resource was still in state from the earlier run. To get a clean
starting point, everything was destroyed and the state file confirmed empty.

From there:

```
terraform plan
```

Shows the `aws_db_instance` to be created.

```
terraform apply -auto-approve
```

The plan stage shows one resource to add, but during the actual operation Terraform also
loads `ephemeral.random_password.db_password`. The video calls this out so it does not cause
confusion: the password is generated at that point.

The database took about five minutes and twelve seconds. Checking `terraform.tfstate`
afterwards, the password is nowhere in it. The `password_wo` attribute shows as `null`.
Terraform has no idea what the password is.

## Points to note

- Write-only arguments require Terraform 1.11 or later, and a resource that supports them.
  Not all resources do, so this has to be checked per resource.
- Write-only arguments accept both ephemeral and non-ephemeral values.
- Terraform does not store write-only arguments in state, so it has no way of knowing whether
  the value has changed. It also cannot create plan diffs for them, since they are not in the
  plan file either.
- This is why providers pair a version argument with a write-only argument. Terraform does
  store the version argument in state and can track when it changes. The version argument is
  the only part of this Terraform can see.
- To trigger an update of a write-only argument, increment the version argument. Going from 1
  to 2 causes a new password to be generated and pushed to `password_wo` on the resource.
- Implementation of write-only arguments and version arguments is provider-specific. The
  registry is the place to check. The AWS provider supports them for a specific set of
  resources, the database being one.

## Part 4: Secrets Manager, for completeness

Explicitly not exam material. It is here because of an obvious practical question: if
Terraform creates the database and nobody knows the password, how do you connect to it?

The answer in the demo is to write the same generated password into AWS Secrets Manager at the
same time, using an `aws_secretsmanager_secret` and an `aws_secretsmanager_secret_version`.

The version was incremented from 1 to 3, then:

```
terraform apply -auto-approve
```

Incrementing the version generates a new password, updates the RDS resource with it, and
stores it in Secrets Manager. The apply modifies the RDS resource, which is expected.

In the AWS console, under Secrets Manager, there is one secret named `db_pass`. Opening it and
choosing to retrieve the secret value shows the password in plain text.

Retrieving it requires permission. The demo account is root or administrator, so it works. A
normal AWS user without Secrets Manager access cannot retrieve the value. Secrets Manager
stores what it holds in encrypted form, using KMS.

Incrementing the version again, from 3 to 4, repeats the whole cycle: new random password, RDS
updated, new value written to Secrets Manager.

## Cleanup

Destroy everything created in this lab or you will be charged. There is an RDS instance
involved and it bills while it exists.

## Documentation referenced

- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance