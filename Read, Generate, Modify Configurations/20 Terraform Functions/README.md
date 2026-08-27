# 20 Terraform Functions

A function is a block of code that takes an input, does one specific job with it, and returns an output. Same idea as functions in Python or anywhere else. The point is not having to write the logic yourself.

Files in this folder:

- `functions.tf`, the IAM user and policy, with the policy loaded through the file function
- `iam-user-policy.json`, the policy document that used to be inline
- `random-file.txt`, the throwaway file used for testing the file function in the console

Docs: https://developer.hashicorp.com/terraform/language/functions

---

## Two examples

`max` takes one or more numbers and returns the largest:

```
max(10, 30, 50)
```

Returns 50. Without the function I would have to write the comparison logic myself.

`file` reads the contents of a file at a given path and returns them as a string:

```
file("./random-file.txt")
```

Returns whatever text is in that file.

## Terraform console

`terraform console` opens a prompt where functions and expressions can be run and evaluated without applying anything. Good for checking what a function actually returns before putting it in the code.

```sh
terraform console
```

Then type the expression and press enter. Both `max` and `file` above were tested this way. Ctrl+D exits.

## Why the file function matters

The starting code creates an IAM user and attaches a policy to it. A new user in AWS has no permissions at all, so the policy is what defines what they can do. Behind the scenes any AWS policy is a JSON document, which the console shows if you look at an attached policy.

The problem is size. The policy JSON was sitting inline in the resource block wrapped in `jsonencode`, and it ran long enough that the actual Terraform code was buried in it. That can be 50 or 100 lines in real cases, and a big block like that is easy to break while editing.

Moving it out:

```hcl
resource "aws_iam_user_policy" "lb_ro" {
  name = "demo-user-policy"
  user = aws_iam_user.this.name

  policy = file("./iam-user-policy.json")
}
```

The JSON goes into `iam-user-policy.json` on its own, and `jsonencode` comes off since the file is already JSON text. The resource block is now short enough to read at a glance.

Running `terraform plan` after the move showed no changes, which is the confirmation that the two versions produce the same result. To be sure it was not just state making things look fine, the video destroys everything and applies again from the smaller code, and the user comes back with the same policy attached.

Note on the workflow: `terraform validate` right after opening the folder complained that the AWS provider was not available. `terraform init` fixed that, and validate then passed.

## Categories

HashiCorp groups the built-in functions into categories in the docs, numeric, string, collection, filesystem and others. `max` is under numeric, `file` is under filesystem. Each function page has a description and examples, so finding the right one is mostly a matter of guessing the category.

## The exam point

Terraform does not support user defined functions. Only the built-in ones can be used. There is no way to write your own.