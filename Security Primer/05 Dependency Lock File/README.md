# 05 - Dependency Lock File

Section 6: Security Primer

## What this video covers

What `.terraform.lock.hcl` is, why it exists, what happens when the version in your code stops
matching it, and how to move to a different provider version on purpose.

## Background: independent release cycles

Terraform and the provider plugins are managed separately and release on their own schedules.
There are thousands of providers, each with its own cycle. Terraform can sit on version 1.2
while the AWS provider moves from version 1 to 2 to 3 underneath it.

That independence is useful, but it creates a problem in production.

### The scenario

You write code against Terraform 1.2. At the time you run `terraform init`, only version 1 of
the AWS provider exists, so that is what gets installed. You test the code and all its modules
against version 1, build the infrastructure, and commit everything to GitHub.

Weeks pass. Version 2 of the provider is released, then version 3.

A month or two later someone else in the organization clones your repository and runs
`terraform init`. They get version 3. Your code may not work against version 3.

Reasons the video gives for that: a bug at the plugin level, or the plugin has introduced new
functionality that expects the code to be adjusted. If the code stops working against a newer
plugin, the provider's GitHub issues page is where to look. The video is clear that this does
not happen often, but it happens.

## First answer: version constraints

Inside `required_providers` you specify the version the code was tested against. The
constraint can be a range, in which case any matching version might be installed (4.2, 4.4,
4.6, and so on), or it can pin an exact version such as 4.4.

## Second answer: the lock file

Once `terraform init` selects a version that satisfies the constraint, Terraform records that
selection in `.terraform.lock.hcl` and reuses it by default afterwards.

The file holds both the constraint from your code and the exact version that was resolved. In
the example, the constraint allows 4.0 and up, and the version actually downloaded on the
first init was 4.62.0.

The effect: another developer pulling the same code later gets 4.62.0, even if 4.7, 4.8 or 4.9
have been released in the meantime. The lock file, not the constraint, decides.

## Walkthrough

The working folder is `kplabs-terraform` and contains a single file, `demo.tf`, with a
`required_providers` block carrying a version range.

```
terraform init
```

Terraform resolved the constraint and installed 4.62.0. The video notes that running the same
thing weeks later might land on 4.7 or 4.8 instead, depending on what has been released.

After the init, the folder contains a new file, `.terraform.lock.hcl`. Opening it shows the
constraint as written in the code, plus the resolved version 4.62.0.

### What happens when the code and the lock file disagree

Suppose 4.62.0 turns out to have a problem and you want to go back to 4.60. You edit `demo.tf`
to specify version 4.60 and run:

```
terraform init
```

This errors out. The version in the code no longer matches what is recorded in the lock file.

### Upgrading or downgrading on purpose

HashiCorp's recommended way through this is the `-upgrade` flag:

```
terraform init -upgrade
```

This time the 4.60 provider was installed, matching what `demo.tf` now asks for.

## Checksums

When a provider is installed for the first time, Terraform also pre-populates the lock file
with hash values, taken from the checksums covered by the provider developers' cryptographic
signature. The lock file holds several, corresponding to the different platforms that provider
version supports.

The effect is that only the exact version passes. If there is a mismatch between the provider
plugin and the signature, the initialization fails.

## Limitation

The dependency lock file tracks provider dependencies only. It does not record version
selections for remote modules. For those, Terraform always picks the newest available version
that satisfies the constraint.