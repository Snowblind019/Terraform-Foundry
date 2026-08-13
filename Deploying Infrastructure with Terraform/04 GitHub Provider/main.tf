# GitHub is a partner tier provider under the "integrations" namespace, not
# "github", so the source has to be spelled out here or init won't find it.
terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

# The provider needs a PAT with Repository permissions > Administration set to
# read and write. It reads GITHUB_TOKEN from the environment on its own, so I
# leave this empty rather than hardcoding the token. A PAT with admin rights in
# a tracked file gets revoked by GitHub's secret scanning the second it's pushed,
# and deservedly so.
provider "github" {}

# github_repository = the resource type
# test              = the local name, Terraform side only
# name              = what the repo is actually called on GitHub
resource "github_repository" "test" {
  name        = "test"
  description = "Creating a github repo with terraform"

  # public or private
  visibility = "public"
}
