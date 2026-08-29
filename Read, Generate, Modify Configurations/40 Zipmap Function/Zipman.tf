provider "aws" {
  region = "us-west-2"

  # Placeholders. Terraform reads credentials from the AWS CLI config and
  # environment variables on its own, so these two lines are not needed.
  access_key = "YOUR-ACCESS-KEY"
  secret_key = "YOUR-SECRET-KEY"
}

# Three IAM users. count.index is 0, 1, 2, so the names come out as
# demo-user.0, demo-user.1 and demo-user.2.
resource "aws_iam_user" "lb" {
  name  = "demo-user.${count.index}"
  count = 3
  path  = "/system/"
}

# Splat expression. [*] pulls the attribute off all three instances at once and
# returns them as a list, rather than having to write out lb[0].arn, lb[1].arn
# and so on.
output "arns" {
  value = aws_iam_user.lb[*].arn
}

# zipmap takes a list of keys and a list of values and pairs them by position.
# Here the keys are the three user names and the values are the three ARNs, so
# the output is one map with each name against its own ARN instead of two
# separate lists you have to line up yourself.
output "zipmap" {
  value = zipmap(aws_iam_user.lb[*].name, aws_iam_user.lb[*].arn)
}