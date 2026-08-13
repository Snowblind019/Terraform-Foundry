# 03 - Provider Tiers, Namespaces, and required_providers

## The three tiers

The registry sorts providers into three tiers, and it's basically a trust ranking.

**Official.** Owned and maintained by HashiCorp. AWS, Azure, GCP, Kubernetes, Active Directory, all the HashiCorp products. This is what you want in production.

**Partner.** Maintained by the technology company itself, with a direct partnership with HashiCorp. Alibaba Cloud, Oracle Cloud Infrastructure, DigitalOcean, GitHub. These are generally solid too.

**Community.** Written and maintained by individuals. Use with caution. If there's a bug, it gets fixed when the one person maintaining it has a free weekend, and sometimes that never happens. Fine for a lab, risky for anything you depend on.

## Namespaces

Every provider lives under a namespace, which is just the org that publishes it. You can read it straight off the registry URL:

```
registry.terraform.io/providers/hashicorp/aws/latest/docs
                                ^^^^^^^^^ namespace

registry.terraform.io/providers/digitalocean/digitalocean/latest/docs
                                ^^^^^^^^^^^^ namespace

registry.terraform.io/providers/integrations/github/latest/docs
                                ^^^^^^^^^^^^ namespace
```

Everything official is under `hashicorp`. Everything else is under whatever the publisher is called. Note that the namespace and the provider name aren't always the same word, and they aren't always what you'd guess. The GitHub provider isn't under `github`, it's under `integrations`. That one is easy to get wrong.

## Why this matters: the init failure

Terraform assumes `hashicorp` when you don't tell it otherwise. So if you write this:

```hcl
provider "digitalocean" {}
```

and run `init`, it goes looking for `registry.terraform.io/hashicorp/digitalocean`, doesn't find it, and fails with an error about not being able to query the available providers. Nothing is wrong with your syntax. Terraform just looked in the wrong namespace because you never gave it the right one.

## The fix: required_providers

The source goes in a `terraform` block, not in the provider block:

```hcl
terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  # provider specific config goes here
}
```

Correcting myself again from earlier notes: you **cannot** write `provider "digitalocean/digitalocean" {}`. The label on a provider block is only ever the short local name. The `namespace/name` path belongs in `required_providers`, keyed by that same short name. Terraform reads the `terraform` block first, learns where `digitalocean` comes from, and then the provider block below matches up by name.

Breaking down what's in there:

- The key (`digitalocean`) is the local name you'll use in provider blocks and as the prefix on resource types.
- `source` is `namespace/name`, copied off the registry page.
- `version` is a constraint. `~> 2.0` means "any 2.x, but not 3.0." That's the pessimistic operator, and it's how you avoid a major version bump silently breaking everything on a future `init`.

Every provider's registry page has this block pre-written at the top under "Use Provider." Copy it, don't type it from memory.

## Does this apply to official providers too

Yes, and it's usually good practice. `provider "aws" {}` on its own works because Terraform defaults to the `hashicorp` namespace and finds it. But writing it out explicitly pins the version, which matters once more than one person is running the code:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

Short version of the rule: for HashiCorp providers it's optional but recommended. For partner and community providers it's mandatory, because Terraform has no way to find them otherwise.

## Files

- `main.tf` - required_providers for a partner provider alongside the usual AWS setup.
