# 15 Fetching Data from Map and List

Last two videos were about declaring lists and maps. This one is about pulling one specific value back out of them.

Files in this folder:

- `fetching-data-map-list.tf`, one EC2 instance plus both variables

---

## Pulling a value out of a map

A map is keyed, so the key is what you reference:

```hcl
variable "types" {
  type = map
  default = {
    us-east-1  = "t2.micro"
    us-west-2  = "t2.nano"
    ap-south-1 = "t2.small"
  }
}

instance_type = var.types["us-west-2"]
```

`terraform plan` showed `t2.nano`. Changed the reference to `ap-south-1`, planned again, and it showed `t2.small`. The variable is the whole map, the brackets pick one entry out of it.

I use the bracket form with the key quoted. It works no matter what the key looks like, including keys with dots or ones that start with a digit, so there is nothing to think about.

## Pulling a value out of a list

A list has no keys, only positions, and positions start at zero:

```hcl
variable "list" {
  type    = list
  default = ["m5.large", "m5.xlarge", "t2.medium"]
}
```

| Index | Value |
|---|---|
| `var.list[0]` | `m5.large` |
| `var.list[1]` | `m5.xlarge` |
| `var.list[2]` | `t2.medium` |

`var.list[1]` planned as `m5.xlarge`, `var.list[0]` as `m5.large`. Zero based, so the last index is always one less than the number of items. That off by one is the whole trick here and it is worth being blunt about it, `[1]` is the second element, not the first.

## What happens when the reference is wrong

The video does not cover this, but it is where the real time gets lost:

- **Index past the end of a list**, say `var.list[5]` on a three item list, fails at plan time with an index out of range error. It does not return empty.
- **Key that is not in the map**, say `var.types["eu-west-1"]`, also fails, telling you the key does not exist.

Both fail during plan rather than apply, which is the good outcome. Nothing gets half built.

Two functions that soften this when the value might legitimately be missing:

```hcl
lookup(var.types, "eu-west-1", "t2.micro")   # falls back instead of failing
element(var.list, 5)                          # wraps around instead of failing
length(var.list)                              # 3
```

`element` wraps by taking the index modulo the length, so index 5 on a three item list gives you index 2. That behaviour is exactly what makes it show up alongside `count.index` later in the course.

## Why this pattern exists

The map version is the useful one in real configs. Instance types and AMI IDs differ per region, so keying a map by region and looking it up means one config works everywhere instead of being edited per environment.

Where the video hardcodes both sides:

```hcl
provider "aws" {
  region = "us-west-2"
}

instance_type = var.types["us-west-2"]
```

the region is written twice, and changing one without the other silently gives the wrong instance type. Better to drive both off one input:

```hcl
variable "region" {
  type    = string
  default = "us-west-2"
}

provider "aws" {
  region = var.region
}

instance_type = var.types[var.region]
```

Now the region is set in one place and the lookup follows it.

## Security note on the provider block

The video's provider block has `access_key` and `secret_key` written into it. Do not copy that. Anything in a `.tf` file goes into git, and those are long lived IAM user credentials. Use the environment variables, a named profile in `~/.aws/credentials`, or a role, and leave the provider block with just the region. My file here has them stripped out for that reason.

---

## Summary

| | List | Map |
|---|---|---|
| Referenced by | position | key |
| Syntax | `var.list[1]` | `var.types["us-west-2"]` |
| Starts at | 0 | not applicable |
| Missing reference | index out of range error | key does not exist error |
| Safe accessor | `element(list, index)` | `lookup(map, key, default)` |

---

## Commands run

```bash
terraform plan
```