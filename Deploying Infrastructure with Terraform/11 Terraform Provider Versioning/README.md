# 11 - Provider Versioning and the Lock File

## Two version numbers, not one

Terraform and its providers ship separately. Terraform CLI is on its own release cycle, and the AWS provider is on a completely different one, maintained by a different team against a different API. Same for every other provider. Upgrading one doesn't upgrade the other.

The practical effect: if you don't say which provider version you want, `terraform init` takes the newest one available at the moment you run it. Which means the same repo, initialized by two people a month apart, can end up running against two different provider versions and behaving differently. Nobody changed the code.

That's the problem versioning constraints solve.

## Where the constraint goes

Back in the `required_providers` block from section 03:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
```

The registry page for any provider gives you this block pre-filled with a pinned exact version. Copy it, then decide how tight you want the constraint to be.

## The operators

| Constraint | Meaning | Allows | Blocks |
| --- | --- | --- | --- |
| `3.27.0` | Exactly this | 3.27.0 only | Everything else |
| `>= 1.0` | This or newer | 1.0, 2.5, 4.0 | 0.9 |
| `<= 1.0` | This or older | 0.8, 1.0 | 1.1 |
| `>= 2.10, <= 2.30` | Range, both ends | 2.10 through 2.30 | 2.9, 2.31 |
| `~> 2.0` | Any 2.x | 2.1, 2.20, 2.99 | 1.9, 3.0 |
| `~> 2.10` | Any 2.10.x | 2.10.1, 2.10.9 | 2.11 |

The tilde is called the pessimistic constraint operator, and it's the one to actually understand because its behaviour changes depending on how many version segments you write. `~> 2.0` pins the major and lets the minor float. `~> 2.10` pins major and minor and lets only the patch float. Same operator, two very different levels of tightness, and the difference is one number.

`~>` at the major level is the usual default. It lets you pick up bug fixes and new resource types within a major version while blocking the breaking-change release.

## The lock file

Run `init` and you get `.terraform.lock.hcl` next to your config. Open it and it records three things per provider: the full source address, the exact version that got selected, and the constraint that was in effect when it was selected.

The behaviour is what matters:

> Once a version is recorded in the lock file, `init` reselects that exact version every time, even if a newer one within your constraint has been released.

So `~> 3.0` doesn't mean "grab the newest 3.x on every init." It means "the first time, grab the newest 3.x and then stick to it." That's the whole point. Everyone who clones the repo gets byte-identical provider binaries, and a provider release on a Tuesday doesn't silently change what your CI is running.

**Commit the lock file.** It's the one Terraform-generated file that belongs in git. `.terraform/` and `*.tfstate` stay out, `.terraform.lock.hcl` goes in. That's why the repo gitignore has the negation line on it.

## When the lock file and the constraint disagree

Change `~> 3.0` to `~> 2.0` and run `init`:

```
Error: Failed to query available provider packages
...locked provider registry.terraform.io/hashicorp/aws 3.27.0 does not match
configured version constraint ~> 2.0
```

The lock says 3.27.0, the config now says 2.x, and Terraform refuses to guess which one you meant. That's a feature. It means nobody quietly downgrades a provider by editing one line.

Two ways through it:

```bash
terraform init -upgrade
```

This re-resolves against the current constraint and rewrites the lock file with whatever it picks. This is the correct way, and it's also how you deliberately move up to a newer version within an existing constraint.

The other way is deleting `.terraform.lock.hcl` and running `init` again, which is what the video does. It works, and it's fine in a scratch folder while you're experimenting with constraint syntax. Don't build the habit. In a real repo, deleting the lock file throws away the pinning for every provider at once so you can change one, and `-upgrade` does the same job without the collateral.

## Should you upgrade at all

The honest answer is that it depends on whether you need something in the newer version.

The usual forcing function is a new service or a new resource argument. The provider is what talks to the API, so a resource type that didn't exist when your pinned version shipped simply isn't available to you. If AWS launches something and you want to manage it in Terraform, you upgrade.

Absent that, "it works" is a reasonable reason to stay put for a while. But not forever, because the gap you eventually have to cross gets wider the longer you leave it, and crossing several major versions at once is much worse than crossing one. Either way, a major version bump is a change to be tested like any other. Run it against a non-production workspace and read the plan before assuming it's a no-op.

## Terraform's own version

Same idea, different block. Worth setting alongside the provider constraints:

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

This one isn't lockable the way providers are, since it constrains the binary running the code rather than something Terraform downloads. It just errors out if someone runs it with a CLI that's too old.

## Files

- `main.tf` - the version block with the constraint variants written out.
