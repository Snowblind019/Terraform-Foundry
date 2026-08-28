# The course version of this file hardcodes access_key and secret_key here.
# Leaving them out so credentials come from the AWS CLI configuration.
provider "aws" {
  region = "us-west-2"
}

# Three IAM users. count.index is appended to the name so they do not collide,
# giving iamuser.0, iamuser.1 and iamuser.2.
resource "aws_iam_user" "lb" {
  name  = "iamuser.${count.index}"
  count = 3
  path  = "/system/"
}

# Because this resource uses count, aws_iam_user.lb is a list rather than a
# single object. [*] is the splat expression, it walks every element and pulls
# the arn attribute from each, so this returns all three ARNs.
#
# The first version of this output used a fixed index instead:
#
#   value = aws_iam_user.lb[0].arn
#
# which returns only the ARN of the user at index 0.
output "arns" {
  value = aws_iam_user.lb[*].arn
}