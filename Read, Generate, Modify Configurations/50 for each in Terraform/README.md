# 50 for_each Meta Argument

One resource block normally maps to one real object. `for_each` lets a single block create one object per item in a map or set, each with its own configuration.

Files in this folder:

- `for-each.tf`

Docs:

- https://developer.hashicorp.com/terraform/language/meta-arguments/for_each
- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance

---

## Why not just count

Managing several similar objects by writing a resource block for each one works, but it gets long fast. Five IAM users means five blocks. Fifty means fifty.

There are two meta arguments for this. `count` is for multiple copies of the same object where the configuration does not differ between them. `for_each` is for the case where the blocks are the same resource type but each one needs a slightly different value.

Five IAM users each with a different name is the second case, so `count` does not fit. The `name` attribute changes per user, and that is exactly what `for_each` handles.

## How it works

Give `for_each` a map or a set of strings, and Terraform creates one instance for each member of it.

```hcl
variable "user_names" {
  type    = set(string)
  default = ["alice", "bob", "john", "james"]
}

resource "aws_iam_user" "this" {
  for_each = var.user_names
  name     = each.value
}
```

`for_each = var.user_names` is where the values come from. `name = each.value` is the per item value being used.

Terraform reads the set, then behind the scenes builds a separate `aws_iam_user` resource for each entry, one with the name alice, one with bob, and so on. The single block in the file stands in for all of them.

Declaring the type as `set(strings)` fails on init with an invalid type specification error, saying the keyword `strings` is not a valid type specification. It is `string`, singular.

`terraform plan` after that lists an `aws_iam_user` for each name. Adding `james` to the default list and re-running plan comes back with four to add. No new resource block needed, just the extra list item. `terraform apply -auto-approve` creates all four users.

## The each object

When `for_each` is in use, an `each` object is available inside the block with two attributes:

- `each.key`
- `each.value`

The IAM user example above uses `each.value`. `each.key` becomes useful with maps.

## for_each with a map

```hcl
variable "my-map" {
  default = {
    key  = "value"
    key1 = "value1"
  }
}

resource "aws_instance" "web" {
  for_each      = var.my-map
  ami           = each.value
  instance_type = "t3.micro"

  tags = {
    Name = each.key
  }
}
```

A map is key value pairs, so `for_each` can read both sides. `each.value` pulls the value, `each.key` pulls the key. Here the AMI takes the value and the Name tag takes the key.

`terraform plan` shows two to add. The first has ami `value` and Name tag `key`, the second has ami `value1` and Name tag `key1`.

## key and value on a set

A set has no key value pairs, so with a set both `each.key` and `each.value` refer to the same item. Switching the IAM user example from `each.value` to `each.key` and running plan comes back with no changes.

Since both do the same thing there, `value` is the clearer one to use. `each.key` is for when there actually are key value pairs to distinguish.

## Commands used

```sh
terraform init

terraform plan

terraform apply -auto-approve
```