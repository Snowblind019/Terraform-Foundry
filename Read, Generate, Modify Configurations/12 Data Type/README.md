# 12 Data Type

Every value in a configuration has a type. This video covers what the types are, how to pin a variable to one, and how to work out which type an argument expects.

Docs referred to: [aws_instance resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance)

Files in this folder:

- `data-types.tf`, the IAM user with a typed variable, plus the EC2 example from the second half of the video

---

## What a data type is

The type of the value, not the value itself.

| Value | Type |
|---|---|
| `"Hello World"` | string |
| `7575` | number |

Anything in quotes that is text is a string. `"earth"`, `"KPLabs"`, all strings. This is the same idea as in Python or Java, so it carries over.

## Restricting a variable to a type

The setup: the company wants IAM usernames created by Terraform to be employee IDs, so numbers only, not names.

Started with the user hardcoded:

```hcl
resource "aws_iam_user" "lb" {
  name = "loadbalancer"
}
```

`terraform apply` created a user called `loadbalancer` in the console. Destroyed it, then swapped the name out for a variable:

```hcl
variable "username" {}

resource "aws_iam_user" "lb" {
  name = var.username
}
```

No value and no type, so `terraform plan` prompted for it. Typed `zeal` and it happily planned a user called `zeal`. Nothing stopping it.

Then added the type:

```hcl
variable "username" {
  type = number
}
```

Ran plan again, entered `zeal`, and this time it stopped:

```
Invalid value for input variable
...a number is required
```

So the type constraint is enforced at the point the variable is set, before Terraform builds a plan or talks to AWS at all. That is the useful part. A bad value fails immediately instead of failing halfway through an apply.

One thing worth knowing that the video does not cover: the check is convertibility, not literal type. `"5"` typed at the prompt is accepted for a `number` variable because Terraform can convert it. `"zeal"` is not convertible, so it fails. Same in the other direction, a number assigned to a string argument gets converted, which is why `name = var.username` works at all when `username` is a number and IAM names are text.

## The full list

| Type | What it is |
|---|---|
| string | a sequence of characters, text |
| number | a numeric value |
| bool | true or false |
| list | an ordered sequence of values |
| set | a collection of unique values, no order |
| map | key value pairs |
| null | absence of a value |

Each of the collection types gets its own video later in the section. For now the point is just that they exist and that the argument decides which one is required.

## Working out what an argument expects

This is the half of the video that actually matters day to day. Looking at the `aws_instance` example in the docs, some arguments take a plain value, some take curly braces, some take square brackets:

```hcl
instance_type = "t3.micro"
tags          = { Name = "HelloWorld" }
owners        = ["099720109477"]
```

Guessing at which is which does not work, swapping the braces for brackets fails. The answer is in the argument reference on the resource page, where each argument states its type. `tags` says map. `vpc_security_group_ids` says a list of security group IDs.

Reproduced the failure on purpose. Passed the security group as a bare string:

```hcl
vpc_security_group_ids = "sg-06dc77ed59c310f03"
```

`terraform plan` returned an incorrect attribute value type error. Wrapped it in square brackets and the same plan ran fine:

```hcl
vpc_security_group_ids = ["sg-06dc77ed59c310f03"]
```

Nothing changed except the type of the value.

Small accuracy note for later: the docs write that argument as a list, but the provider schema actually types it as a set of strings. It reads the same in the config, square brackets either way. The difference is that a set has no ordering and no duplicates, which is why reordering those IDs does not show up as a change in a plan. There is a dedicated set video later in the section.

## Takeaway

Two habits out of this one. Put a `type` on variables that have a real constraint, so bad input fails at the prompt instead of during an apply. And when an argument throws an incorrect attribute value type error, go to the resource page and read what type that specific argument wants rather than guessing at the syntax.

---

## Commands run

```bash
terraform apply
terraform plan
terraform destroy
```