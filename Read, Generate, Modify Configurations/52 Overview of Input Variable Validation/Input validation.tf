terraform {
  required_providers {
    aws = "~>5.6"
  }
}

# Example 1: provider side validation catching the problem.
#
# This name plans fine. Adding a # on the end makes it kplabs-user-01# and
# plan fails right there with an invalid value for name, since # is not in
# the allowed character set for IAM usernames.
resource "aws_iam_user" "dev" {
  name = "kplabs-user-01"
}

# Example 2: provider side validation missing the problem.
#
# S3 bucket names have to be 3 to 63 characters. hi is two, so it is invalid,
# but plan comes back clean anyway. The failure only shows up on apply, when
# the call reaches AWS and AWS rejects it as not a valid bucket name.
#
# Uncomment to reproduce it.
#
# resource "aws_s3_bucket" "example" {
#   bucket = "hi"
# }