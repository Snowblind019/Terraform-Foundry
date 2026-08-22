# 13 Data Type - List

A list holds a collection of values under one variable or argument instead of a single value. Plenty of resource arguments will not accept anything else.

Docs referred to: [aws_instance resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance)

Files in this folder:

- `list-data-type.tf`, the variable and output, with the EC2 example commented out underneath

---

## What it looks like

Square brackets, values separated by commas:

```hcl
["A", "B", "C"]
```

As a variable with a default:

```hcl
variable "cities" {
  type    = list
  default = ["Mumbai", "Bangalore", "Delhi"]
}
```

Compare that to `instance_type = "t3.micro"`, which is one value and one value only. Some arguments take a single value, some expect a collection, and the docs say which is which. On the `aws_instance` page, `volume_tags` says map and `vpc_security_group_ids` says list.

## The variable demo

Started with no type constraint at all:

```hcl
variable "my-list" {}

output "variable_value" {
  value = var.my-list
}
```

`terraform apply -auto-approve` prompted for the value, typed `hello-world`, and the output printed it back. Nothing enforced yet.

Then added the constraint:

```hcl
variable "my-list" {
  type = list
}
```

Ran apply again, typed `hello` at the prompt, and it failed with:

```
No value for required variable
```

That error is genuinely unhelpful, it reads like nothing was entered when something clearly was. What actually happened is that `hello` on its own is not valid list syntax, so Terraform could not parse it into a value and treated the variable as unset. Knowing the type is what makes the message make sense.

Typed it properly the second time:

```
["test", "hello"]
```

Applied fine, and the output printed both values. Worth noting the difference from a string variable: at the prompt a string is typed bare, but a list has to be typed with the brackets and the quotes.

## Why arguments need lists

The realistic case is security groups. An EC2 instance can sit in more than one, and the console lets you tick several, so the argument has to accept a collection.

The wrong way, which looks reasonable:

```hcl
vpc_security_group_ids = "sg-1234", "sg-5678"
```

`terraform plan` errors out. The right way:

```hcl
vpc_security_group_ids = ["sg-1234", "sg-5678"]
```

Plan then shows both IDs on the instance.

The part worth remembering: **a single value still needs the brackets**. If the argument wants a list, one element is `["sg-1234"]`, not `"sg-1234"`. Dropping the brackets because there is only one value is an error, not a shortcut. That one shows up in exam questions.

## Constraining what goes inside

The type can also pin down the element type:

```hcl
variable "my-list" {
  type = list(number)
}
```

Now the list only accepts numbers. Entering `["hello"]` at the prompt fails, entering `[1, 2]` works.

Two additions past the video here, both exam relevant:

- Bare `list` is shorthand for `list(any)`, kept around for compatibility with older configs. `list(string)` or `list(number)` is the modern way to write it, and being explicit is what makes the constraint actually do something.
- With `list(any)` Terraform unifies the element types rather than rejecting a mix. `[1, "hello"]` does not error, it converts the number to a string and gives you a list of strings. So a bare `list` is a much weaker check than it looks.

Also, `my-list` with a hyphen is legal but unusual. Underscores are the convention for variable names in Terraform, and the docs style uses them throughout.

## Takeaway

Check the argument reference before writing a value. If it says list, use brackets, including when there is only one item. And put a real element type on list variables rather than bare `list`, otherwise the constraint is close to no constraint.

---

## Commands run

```bash
terraform apply -auto-approve
terraform plan
```