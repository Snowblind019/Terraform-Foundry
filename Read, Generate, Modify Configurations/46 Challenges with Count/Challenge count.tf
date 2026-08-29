provider "aws" {
  region = "us-west-2"

  # Left empty in the video. Terraform reads credentials from the AWS CLI
  # config and environment variables, so these two lines are not needed.
  access_key = ""
  secret_key = ""
}

# The list the resource indexes into. Position matters here, not just contents.
variable "iam_names" {
  type    = list
  default = ["user-01", "user-02", "user-03"]
}

resource "aws_iam_user" "iam" {
  # count.index is 0, 1, 2, so each user takes the name at that position in the
  # list. State stores each instance against its index key, which is how
  # Terraform maps the real IAM user back to a list entry.
  #
  # Appending to the end of the list is safe, nothing already there moves.
  #
  # Inserting at the front is not. Every entry shifts down a position while the
  # index keys in state stay where they are, so plan comes back wanting to
  # change every existing user rather than just adding one. On IAM users that
  # apply fails outright, since they cannot be renamed in place.
  #
  # count suits resources that are near identical. Where each one needs
  # different values, for_each is the right meta-argument instead.
  name  = var.iam_names[count.index]
  count = 3
  path  = "/system/"
}