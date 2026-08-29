# 39 List and Map Variables

Two of the variable types, a list and a map, and how you pull a single value out of a list by its index.

Files in this folder:

- `main.tf`

Docs:

- https://developer.hashicorp.com/terraform/language/expressions/types
- https://developer.hashicorp.com/terraform/language/values/variables

---

## Lists

A list holds multiple values in order. Declared with `type = list` and a default holding three instance types:

```hcl
variable "list" {
  type    = list
  default = ["m5.large", "m5.xlarge", "t2.medium"]
}
```

Nothing here restricts the resource to one value. The list is just the set of options sitting in the variable.

## Pulling one value out

The instance references the list by index:

```hcl
instance_type = var.list[1]
```

Index starts at 0, so:

- `var.list[0]` is `m5.large`
- `var.list[1]` is `m5.xlarge`
- `var.list[2]` is `t2.medium`

So this configuration builds an `m5.xlarge`. Changing the index is enough to change the instance type, no edit to the variable needed.

Going past the end of the list, `var.list[3]` here, fails at plan time rather than falling back to anything.

## Maps

A map is key and value pairs instead of an ordered list:

```hcl
variable "types" {
  type = map
  default = {
    us-east-1  = "t2.micro"
    us-west-2  = "t2.nano"
    ap-south-1 = "t2.small"
  }
}
```

The keys here are regions and the values are instance types, so the map is a lookup table of which instance type to use in which region. You reference a value by its key, `var.types["us-west-2"]`, rather than by position.

The map is declared in this configuration but not used by the instance. The instance is still on `var.list[1]`. The map is there to show the type alongside the list.

## Credentials in the provider block

The provider block in this lab has `access_key` and `secret_key` written directly in it:

```hcl
provider "aws" {
  region     = "us-west-2"
  access_key = "YOUR-KEY"
  secret_key = "YOUR-KEY"
}
```

I left the placeholders in rather than my real keys. Terraform picks up credentials from the AWS CLI configuration and environment variables on its own, so the provider block only needs the region.

## Bare list and map are the old form

Written as `type = list` and `type = map` with no type inside them. Current Terraform wants the element type as well:

```hcl
type = list(string)
type = map(string)
```

The bare forms still work, they just produce a deprecation warning on plan.