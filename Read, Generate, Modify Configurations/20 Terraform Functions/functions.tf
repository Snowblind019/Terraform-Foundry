provider "aws" {
  region = "ap-south-1"
}

resource "aws_iam_user" "this" {
  name = "demo-kplabs-user"
}

resource "aws_iam_user_policy" "lb_ro" {
  name = "demo-user-policy"
  user = aws_iam_user.this.name

  # The policy JSON used to sit inline in this block, wrapped in jsonencode.
  # The file function reads the file at the given path and returns its contents
  # as a string, so the policy lives in its own file now and this stays short.
  # The path is relative to this directory.
  policy = file("./iam-user-policy.json")
}