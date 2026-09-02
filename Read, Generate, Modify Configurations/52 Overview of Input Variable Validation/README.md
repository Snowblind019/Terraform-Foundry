# 52 Input Variable Validation

Plan succeeding and apply failing right after is a common problem, and it comes down to values never being checked before the API call goes out. Validation blocks let you do that checking yourself.

Files in this folder:

- `input-validation.tf`

Docs:

- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
- https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html

---

## The problem

You write the HCL, run `terraform plan`, and it comes back clean showing the resource and its attributes. Then `terraform apply` errors out the moment Terraform tries to actually create the thing. In automation that is a real problem, since the plan gave no warning.

The cause is missing validation. Every AWS service has restrictions and limits on naming, capacity and so on. IAM usernames, for example, have to be alphanumeric plus a specific set of characters: `+`, `=`, `,`, `.`, `@`, `_` and `-`. Anything else is not allowed.

## Provider side validation

For a lot of resources, Terraform and the provider do check the input and catch the problem early.

```hcl
resource "aws_iam_user" "dev" {
  name = "kplabs-user-01"
}
```

That plans fine. Changing the name to `kplabs-user-01#` and running plan again fails at the plan stage with an invalid value for name, since `#` is not in the allowed character set for IAM usernames. No apply attempted, no AWS call made.

## Where it does not catch it

This works for many resources but not all. The S3 bucket naming rules say a bucket name has to be between 3 and 63 characters long. So `test` is valid and `hi` is not.

```hcl
resource "aws_s3_bucket" "example" {
  bucket = "hi"
}
```

`terraform plan` on that comes back fine. Nothing flags the two character name. Running `terraform apply -auto-approve` gets as far as the API call to AWS, and AWS returns an error saying the specified bucket is not valid.

That is exactly the plan-works-apply-fails situation. Ideally a passing plan means a passing apply.

## What the feature does

For the cases the provider does not cover, HashiCorp added a validation block so the user can enforce rules on the values assigned to an input variable.

Important framing: this is attached to an input variable, and it checks the value being assigned to it. It does not matter where that value comes from. Defined in the variable block, set in a tfvars file, passed on the CLI, all of them get checked.

Example from the video: a `db_password` variable with a constraint that the value has to be at least 12 characters.

Running `terraform plan` with no value set, Terraform prompts for the password. Entering `admin123` errors immediately with a message saying the database password must be at least 12 characters long. Entering something 12 characters or longer plans with no error.

The actual syntax of the validation block is not covered here, that comes in the practical video next.

## Why it matters

- keeps naming standards and other organization practices consistent
- makes the code more predictable, so a passing plan generally means a passing apply
- catches misconfiguration early, which saves time and avoids infrastructure problems later

## Commands used

```sh
terraform plan

terraform apply -auto-approve
```