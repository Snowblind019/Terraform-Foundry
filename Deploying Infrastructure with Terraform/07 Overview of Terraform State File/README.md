# 07 - The State File

This is the one that makes the rest of Terraform make sense.

## The problem it solves

Terraform's whole job is working out the difference between what your code says should exist and what actually exists, then closing that gap. The second half of that is the hard part. If I change `instance_type` from `t3.micro` to `t3.medium` and run apply, how does Terraform know which of the hundreds of instances in the account is the one I meant?

It can't work that out from the code. The code says "an instance with this AMI and this size." That describes a shape, not a specific machine. Something has to hold the mapping between `aws_instance.WinterdayEC2` in my config and `i-0fb40...` in AWS.

That something is the state file.

## What it is

Run `apply` for the first time and a file called `terraform.tfstate` appears next to your config. It's JSON, and it holds everything Terraform learned about each resource it created: the real ID, the instance type, the AMI, the security groups, the private IP, all of it.

From then on, `plan` is a three-way comparison:

1. What the config says you want.
2. What state says was created last time.
3. What the provider API says is out there right now.

Which is also why `plan` on an unchanged config still takes a few seconds. It's refreshing state against the real API before it decides there's nothing to do.

## Losing it

Worth doing this once deliberately to see what happens. Rename the file:

```bash
mv terraform.tfstate terraform.tfstate.old
terraform plan
```

The plan now says it wants to create the instance. Not modify it, create it. Terraform has no memory of ever having built anything, so as far as it's concerned it's starting from nothing.

If you'd run `apply` there, you'd have two instances: the new one Terraform now tracks, and the original one, still running, still billing, now completely orphaned. Terraform won't manage it, won't destroy it, won't even know it exists. The only way back is `terraform import` or deleting it by hand.

Rename it back and `plan` immediately picks the instance back up by ID. Nothing was wrong with the infrastructure, Terraform just had amnesia.

## Never edit it by hand

It's JSON and it's tempting. Don't. A malformed edit corrupts the file and Terraform stops being able to read it at all, and a well-formed edit that's subtly wrong is worse, because now state and reality disagree and you won't find out until an apply does something unexpected.

There are proper commands for this:

```bash
terraform state list                  # everything currently tracked
terraform state show aws_instance.X   # full attributes of one resource
terraform state mv A B                # rename or move a resource in state
terraform state rm aws_instance.X     # stop managing it without destroying it
terraform import aws_instance.X i-0ab # adopt an existing resource into state
```

`state rm` and `import` are the two that get you out of the orphaned-resource situation above. Take a copy of the file before running any of them.

## Treat it as a secret

This is the part the video doesn't emphasize and it's the one that matters most. **State stores attribute values in plaintext, including sensitive ones.** An RDS instance puts its master password in there. `aws_iam_access_key` puts the secret key in there. Private keys, generated passwords, database connection strings, all of it sits in that JSON unencrypted, regardless of whether you marked the variable `sensitive` in your config. The `sensitive` flag only suppresses it from CLI output.

So `*.tfstate` stays in `.gitignore` permanently, and the file gets the same handling as a credentials file. This is already covered in the repo root gitignore.

## After a destroy

`terraform destroy` doesn't delete the state file. You're left with `terraform.tfstate` still sitting there, just with an empty resources array, plus a `terraform.tfstate.backup` alongside it.

The backup file is one single previous version, written on each state change. It's a fail safe for "I just did something stupid thirty seconds ago," not a backup strategy. Anything you actually care about needs real versioning behind it.

## Where this goes next

Everything above assumes state is a local file, which works fine for one person on one laptop and falls apart immediately after that. Two people applying at the same time against the same infrastructure with two separate local state files will overwrite each other's work.

The fix is a remote backend, S3 being the usual one for AWS, with versioning enabled and state locking so a second apply blocks while the first is running. That gets its own section later in the course. For now the thing to internalize is just that state is the source of truth and losing it is the expensive failure mode.

## Pointers

- Default filename is `terraform.tfstate`, format is JSON.
- One state file per directory, which is the real reason this repo is split into folders. Each section tracks only its own resources.
- Never edit manually, use the `state` subcommands.
- Never commit it.
- `destroy` empties it but leaves it behind.

## Files

- `main.tf` - the instance used for the state demo.
