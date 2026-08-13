# 04 - GitHub Provider

The point of this one isn't GitHub. It's proving that the workflow doesn't change when the target does. Different provider, different auth method, different resource types, exact same loop.

## Setting it up

GitHub is a partner tier provider under the `integrations` namespace, so it needs a `required_providers` block:

```hcl
terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}
```

Auth is a personal access token rather than a key pair. To generate one:

Settings > Developer settings > Personal access tokens > Fine-grained tokens > Generate new token.

For creating repos, the permission you need is **Repository permissions > Administration > Read and write.** That's the one covering repo creation, deletion, teams, and collaborators. Everything else can stay at default. Repository access can be set to all repositories for a lab, though scoping it down is better habit.

## Don't put the token in the file

The course writes it inline:

```hcl
provider "github" {
  token = "github_pat_..."
}
```

I'm not doing that. A PAT with admin rights on your repos is not something you want sitting in a file that git is tracking, and GitHub's own secret scanning will revoke it the moment you push anyway. The provider reads `GITHUB_TOKEN` from the environment on its own, so an empty provider block is all that's needed:

```bash
export GITHUB_TOKEN="github_pat_..."
```

```hcl
provider "github" {}
```

Same result, no secret in the repo.

## Creating the repo

```hcl
resource "github_repository" "test" {
  name        = "test"
  description = "Creating a github repo with terraform"
  visibility  = "public"
}
```

`github_repository` is the resource type. `test` after it is the local name, the Terraform-side label. `name` inside the block is what the repo is actually called on GitHub. Those two are separate fields and they don't have to match, I just made them the same here so it's easier to follow.

Then the usual:

```bash
terraform init
terraform plan
terraform apply
```

Plan says "1 to add," apply asks for a `yes`, and the repo shows up in the account.

## What this actually demonstrates

Every provider follows the same shape:

1. Find it on the registry and copy the `required_providers` block off its page.
2. Work out how it wants to authenticate, and feed that in from the environment.
3. Find the resource type you want in the docs and copy the example usage.
4. `init`, `plan`, `apply`.

Step 3 is the only one that changes meaningfully between providers, and it's a docs lookup. The real prerequisite is knowing the platform. If you already understand how GitHub repos or Azure VMs work by hand, writing the Terraform for them is mostly a matter of finding the right argument names.

The docs are also genuinely good about this. Nearly every resource page has a working example at the top you can paste and edit, rather than piecing it together from the argument reference.

## Files

- `github.tf` - the config for this section.
