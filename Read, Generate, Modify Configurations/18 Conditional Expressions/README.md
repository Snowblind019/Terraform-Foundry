# 18 Conditional Expressions

A conditional expression picks between two values based on a condition. It is the one place in an argument where the value is not fixed, it depends on something else in the configuration.

Files in this folder:

- `conditional-expression.tf`, the multi-variable version, with the earlier examples from the video kept as comments

---

## Syntax

```
condition ? true_value : false_value
```

If the condition is true the first value is used, if it is false the second one is used. That is the whole thing.

The condition usually reads a variable, since that is what changes between environments. The expression itself does not launch anything, it just resolves to a value. It gets placed on an argument inside a resource block, and that argument is what does the work.

## The use case

Starting point was a hardcoded instance type:

```hcl
variable "environment" {
  default = "development"
}

resource "aws_instance" "myec2" {
  ami           = "ami-00c39f71452c08778"
  instance_type = "t2.micro"
}
```

The variable exists but nothing reads it, so the plan shows t2.micro every time regardless of what the variable says.

Wiring the two together:

```hcl
instance_type = var.environment == "development" ? "t2.micro" : "m5.large"
```

With the default set to development the plan showed t2.micro. Changing the default to production, or to any other value, made the plan show m5.large. Anything that is not exactly "development" falls to the false side.

## Not equals

The same check can be written the other way round with `!=`:

```hcl
instance_type = var.environment != "development" ? "t2.micro" : "m5.large"
```

With environment set to production, "not development" is true, so t2.micro is used. Setting it back to development makes the condition false and m5.large is used. Same two outcomes as before, but the values on either side of the `:` have effectively swapped meaning, which is worth reading carefully before changing one of these.

## Checking for an empty value

```hcl
instance_type = var.environment == "" ? "t2.micro" : "m5.large"
```

This tests whether the variable has any value at all. With the default set to production the plan showed m5.large. Emptying the default so there is no value left made the condition true and the plan showed t2.micro.

## Multiple conditions

A condition can combine checks with `&&`, so both sides have to be true:

```hcl
variable "environment" {
  default = "production"
}

variable "region" {
  default = "ap-south-1"
}

resource "aws_instance" "myec2" {
  ami           = "ami-00c39f71452c08778"
  instance_type = var.environment == "production" && var.region == "us-east-1" ? "m5.large" : "t2.micro"
}
```

The idea is that production only means production in the main region. With environment as production and region as us-east-1 both halves were true, so the plan used m5.large. Changing region to ap-south-1 left the first half true and the second half false, and the plan dropped to t2.micro. One false half is enough to send the whole thing to the false value.