# 10 - Refresh

Short section, one genuinely nasty failure mode in it.

## What refreshing is

Refreshing is the step where Terraform goes out to the provider API and asks what each resource in state actually looks like right now, then writes the answers back into state. It's how state stops being a snapshot of the moment you applied and starts being current.

You've already been running it. `plan` and `apply` both refresh first, which is the "Refreshing state..." lines scrolling past before any output appears. There is a standalone command, but you almost never want it, and the rest of this section is why.

## plan reads, apply writes

Worth being precise here, because it's the difference between the safe version and the dangerous one.

`terraform plan` refreshes in memory. It uses what it learns to build the diff and then throws it away. Your `terraform.tfstate` on disk is not modified by a plan, ever.

`terraform apply` refreshes and persists. So does the standalone `terraform refresh`, and it does it immediately with no plan shown and no confirmation prompt.

## The failure

Take a working config with an applied instance, then change the region in the provider block:

```hcl
provider "aws" {
  region = "us-west-2"   # was us-east-1
}
```

Run `terraform plan` and it wants to create a new instance. Of course it does, it's looking in the wrong region and there's nothing there. Annoying but harmless, because plan changed nothing. Set the region back and the next plan finds the instance again and reports no changes.

Now do the same thing with `terraform refresh` instead. Terraform queries `us-west-2`, gets nothing back, concludes the instance no longer exists, and writes that conclusion to disk. Open `terraform.tfstate` and it's empty.

Nothing happened to the instance. It's still running in `us-east-1`, still billing, and now completely orphaned because the only record tying it to your config has been erased. Same orphan problem as section 07, arrived at by a different route.

`terraform.tfstate.backup` holds the previous version, so copying it back recovers this one. That backup is one revision deep though, so a second refresh before you notice overwrites the good copy with the empty one.

## The general shape of it

The region change is just the easiest way to demo it. The real rule is broader:

> Refresh cannot tell the difference between "this resource was deleted" and "I can't see this resource."

Anything that makes the API return nothing produces the same result. Wrong region, wrong `AWS_PROFILE`, wrong account, expired SSO session that silently fell back to a different set of credentials, an IAM policy that revoked your `Describe*` permissions. All of those look identical to deletion from where Terraform is standing, and the standalone command commits that interpretation to disk without asking.

Which makes "check what identity you're actually using before touching state" a real habit worth having:

```bash
aws sts get-caller-identity
```

## What to use instead

`terraform refresh` has been deprecated since 0.15.4. The replacement is the flag pair from section 08:

```bash
terraform plan -refresh-only     # show me what changed out there, propose nothing
terraform apply -refresh-only    # write it to state, after showing me and asking
```

The important difference isn't the syntax, it's that `-refresh-only` shows you a plan and waits for a `yes`. In the broken-region scenario it would print that the instance is about to be removed from state, and give you the chance to notice that's wrong. The old command just did it.

There's also `-refresh=false`, which skips the API calls entirely and plans against state alone. Faster on large configurations, and occasionally useful when a provider API is timing out, at the cost of planning against possibly-stale data.

## Why remote state matters

The local `.tfstate.backup` file is a one-revision safety net on a single machine. It's better than nothing and it's not a plan.

An S3 backend with bucket versioning enabled turns "I destroyed my state file" into "restore the previous object version." That's the actual answer, and it's the same reason versioning gets recommended for state buckets everywhere. State locking on top of that stops two people refreshing and applying over each other. Both come later in the course.

## For the exam

- Refresh happens automatically as part of `plan` and `apply`.
- `terraform refresh` as a standalone command is deprecated.
- The supported equivalent is `-refresh-only` on plan or apply.
- `plan` does not modify the state file. `apply` and `refresh` do.

## Files

- `main.tf` - the instance, with the failure sequence written out in comments.