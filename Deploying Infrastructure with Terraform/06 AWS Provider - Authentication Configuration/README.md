# 06 - AWS Provider Authentication

This is the section that retroactively fixes every earlier one. The course hardcodes `access_key` and `secret_key` into the provider block for the first few videos on purpose, so you feel why it's bad, and then walks it back. I skipped ahead and never hardcoded them in this repo, so the code in sections 01 through 03 already looks the way it's supposed to look by the end of this one. This section is the reasoning behind that.

## Why hardcoding is a problem

```hcl
provider "aws" {
  region     = "us-west-2"
  access_key = "AKIA..."
  secret_key = "..."
}
```

That works. It also puts a long-lived credential into a file that git tracks, and from there:

- Push it to a public repo and it's compromised. Bots scrape GitHub for key patterns continuously and the window between push and abuse is measured in minutes, not days.
- Push it to a private repo and every collaborator can read it. If someone else uses your key badly, CloudTrail says you did it. The identity in the logs is the key, not the person holding it.
- Paste the code into a forum or a course Q&A asking why your plan is failing and you've leaked it to strangers. The instructor mentions having to pull student posts and walk them through deactivating keys, which happens often enough that he moved this whole topic earlier in the course.

Deleting the line later doesn't help either. It's still in the git history. Once a key has been committed, the only fix is deactivating it and issuing a new one.

## What we're aiming for

```hcl
provider "aws" {
  region = "us-west-2"
}
```

Region and nothing else, or an empty block if you're setting region from the environment too. Terraform finds credentials on its own. That's the target, and there are a few ways to get there.

## Option A: shared credential files, explicitly

```hcl
provider "aws" {
  shared_config_files      = ["/home/snowy/.aws/config"]
  shared_credentials_files = ["/home/snowy/.aws/credentials"]
  profile                  = "customprofile"
}
```

Note these are lists, and the paths are strings, so the brackets and the quotes both matter. Also note the field names are plural on both, which is easy to get wrong.

This is a real improvement, since the secrets live outside the repo entirely. The problem is the hardcoded path. Ten people on the same repo means ten different home directories, and now everyone has to standardize their filesystem layout just to run a plan. That's a smell.

## Option B: let it find the files itself

If you leave those lines out entirely, Terraform falls back to the default locations:

| OS | Config | Credentials |
| --- | --- | --- |
| Linux / macOS | `~/.aws/config` | `~/.aws/credentials` |
| Windows | `%USERPROFILE%\.aws\config` | `%USERPROFILE%\.aws\credentials` |

Same result, no path in the code, works identically for everyone on the team regardless of where their home directory is. This is the one to use.

## Getting credentials into those files

The files are the same ones the AWS CLI uses, so the simplest way to populate them is to let the CLI do it. On Fedora:

```bash
sudo dnf install awscli2
aws --version
aws configure
```

`aws configure` prompts for access key, secret key, default region, and output format, then writes them into `~/.aws/credentials` and `~/.aws/config`. Terraform picks them up from there with no further configuration.

Worth having the CLI anyway. It's the fastest way to confirm what identity you're actually authenticating as, which matters the moment you have more than one profile:

```bash
aws sts get-caller-identity
```

## The error when it can't find anything

Strip the keys out before setting any of this up and `terraform plan` fails with:

```
No valid credential sources found for AWS Provider
```

That message means Terraform checked every method it knows and came up empty. It's not a syntax problem, it's a "nothing on this machine can authenticate" problem.

## Other methods

Environment variables work too, and they take precedence over the shared files:

```bash
export AWS_ACCESS_KEY_ID="AKIA..."
export AWS_SECRET_ACCESS_KEY="..."
export AWS_REGION="us-west-2"
```

Handy for CI, where there's no home directory worth persisting to. Also handy for a quick override without editing your profile.

Beyond that the provider supports assuming a role:

```hcl
provider "aws" {
  region = "us-west-2"

  assume_role {
    role_arn     = "arn:aws:iam::123456789012:role/TerraformRole"
    session_name = "terraform"
  }
}
```

And IAM Identity Center, which is where you actually want to end up. Long-lived access keys are the thing you're trying to get rid of, not just the thing you're trying to keep out of git:

```bash
aws configure sso
aws sso login --profile my-sso-profile
export AWS_PROFILE=my-sso-profile
```

Terraform reads the SSO profile out of `~/.aws/config` and uses the short-lived session credentials. Nothing durable ever hits disk in a form worth stealing.

## Precedence

Roughly the order Terraform checks, first match wins:

1. Arguments in the provider block (`access_key` / `secret_key`)
2. Environment variables
3. Shared credentials and config files, using `AWS_PROFILE` or `default`
4. Container credentials (ECS / EKS)
5. Instance metadata, if it's running on an EC2 instance with a role attached

That last one is worth remembering. Terraform running on an EC2 instance with an instance profile attached needs no credential configuration at all.

## A note on -auto-approve

The video uses this to skip the confirmation prompt:

```bash
terraform apply -auto-approve
```

Fine for a lab where you're applying the same trivial resource repeatedly. It is exactly the flag you don't want to develop muscle memory for, because it removes the last point where you'd catch a plan that says "must be replaced" on something you can't replace.

## Files

- `main.tf` - the IAM user resource from the video, with a provider block carrying nothing but a region.
