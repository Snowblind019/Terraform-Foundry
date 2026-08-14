# Terraform and its providers version independently, so without a constraint
# here, `terraform init` takes whatever is newest at the moment it runs. Two
# people initializing the same repo a month apart can end up on different
# provider versions with nobody having touched the code.
terraform {
  # Constrains the CLI binary itself, not something Terraform downloads. Just
  # errors out if someone runs this with a version that's too old.
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"

      # ~> 3.0 means any 3.x, never 4.0. Picks up bug fixes and new resource
      # types within the major version while blocking the breaking release.
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

# --- constraint reference ---
#
#   version = "3.27.0"            exact, nothing else
#   version = ">= 1.0"            1.0 or newer, no upper bound
#   version = "<= 1.0"            1.0 or older
#   version = ">= 2.10, <= 2.30"  inclusive range, blocks 2.9 and 2.31
#   version = "~> 2.0"            any 2.x   (major pinned, minor floats)
#   version = "~> 2.10"           any 2.10.x (major AND minor pinned)
#
# The tilde is the pessimistic constraint operator and how tight it is depends
# on how many segments you write. ~> 2.0 and ~> 2.10 are not the same level of
# strictness, which is easy to get wrong by one number.

# --- .terraform.lock.hcl ---
#
# terraform init writes this file recording the source, the exact version
# selected, and the constraint in effect at the time. From then on init
# reselects that exact version even if a newer one within the constraint exists.
#
# So ~> 3.0 does not mean "newest 3.x every init". It means "newest 3.x the
# first time, then stick to it". That's what makes clones reproducible.
#
# COMMIT THIS FILE. It's the one Terraform-generated file that belongs in git.
# .terraform/ and *.tfstate stay out, .terraform.lock.hcl goes in.
#
# Change the constraint so it conflicts with the lock and init refuses:
#   Error: ...locked provider ... does not match configured version constraint
#
# The fix:
#   terraform init -upgrade      # re-resolve and rewrite the lock file
#
# Deleting the lock file also works and is what the course does, but it throws
# away the pinning for every provider at once just to change one. Fine in a
# scratch folder, bad habit in a real repo.
