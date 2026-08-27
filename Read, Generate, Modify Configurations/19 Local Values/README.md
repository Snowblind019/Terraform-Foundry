# 19 Local Values

Local values are the second way to centralize values that repeat across resource blocks. Variables are the first. The difference that matters is that locals can hold expressions and variables cannot.

Files in this folder:

- `local-values.tf`, two security groups, the variable version and the locals version

Docs used: https://developer.hashicorp.com/terraform/language/functions/formatdate

---

## The problem

Starting point was two security groups with the same tag written out twice:

```hcl
resource "aws_security_group" "sg_01" {
  name = "app_firewall"
  tags = {
    Name = "security-team"
  }
}

resource "aws_security_group" "sg_02" {
  name = "db_firewall"
  tags = {
    Name = "security-team"
  }
}
```

Two copies is manageable. Twenty is not, because changing the tag means finding and editing every one of them and hoping none get missed. Hardcoding repeated values is the thing to avoid.

## Centralizing with a variable

```hcl
variable "tags" {
  type = map
  default = {
    Team = "security-team"
  }
}
```

Then both resources reference it:

```hcl
tags = var.tags
```

`terraform apply -auto-approve` created both groups and the console showed the security-team tag on app_firewall and db_firewall.

## Centralizing with locals

```hcl
locals {
  default = {
    Team = "security-team"
  }
}
```

Referenced as `local.default`. The name `default` is arbitrary, it can be anything.

Swapping the resources from `var.tags` to `local.default` and running `terraform plan` showed no changes, which is the confirmation that both approaches resolve to the same value. Changing the locals value to security-teams and planning again showed the tag change on both groups, and the apply pushed it through.

## Why locals exist

Locals can contain expressions and function calls. That is the thing variables cannot do. The video also mentions using `concat` inside a locals block to build a list of instance IDs from several sources, same principle, a value that has to be computed rather than written out.

The example built here adds a creation date to the tags:

```hcl
CreationDate = "date-${formatdate("DDMMYYYY", timestamp())}"
```

`timestamp()` returns the current time, `formatdate` takes a format spec and reshapes it. `DDMMYY` was used first, then changed to `DDMMYYYY` for the full year. The applied tag came out as date- followed by the formatted date.

Putting that same line inside the variable's `default` and running `terraform plan` fails with an error saying function calls are not allowed. Moving the line into the locals block makes the plan run clean. That error is the practical dividing line between the two.

## Which to use

Variables can be overridden from outside the code, through `terraform.tfvars`, environment variables, or the CLI. Locals cannot. The only way to change a local value is to edit the configuration itself.

So variables stay the default choice, especially for anything driven by automation, where being able to feed values in from the environment is the whole point. Locals are for the cases variables cannot cover, mainly computed values, and for avoiding the same expression written out in several places.

## Naming

The block is `locals`, plural. The reference is `local.name`, singular. Defining takes the s, calling does not.

Local values are usually just called locals in conversation.