# 01 - Multiple Provider Configuration

Section 6: Security Primer

## What this video covers

How to deploy resources defined in a single Terraform file into more than one region, using
the `alias` meta argument on the provider block.

## The problem

Everything up to this point has used a single provider configuration: one `provider "aws"`
block with one `region`, and every resource in the file lands in that region. If the provider
block is left out entirely, the region gets picked up from somewhere else in the environment,
an environment variable or the AWS config file, but the outcome is the same. One region for
the whole file.

The requirement in the video is a single `.tf` file containing two different resource types
where each one has to go to a different region. The slide uses an EC2 instance and a security
group as the example: the EC2 instance into Singapore, the security group into Mumbai.

## The solution: alias

Terraform allows any number of alternate provider configurations for the same provider type,
as long as each of the extra blocks carries an `alias` argument. The default block, the one
with no alias, stays as the default.

```
provider "aws" {
    region = "ap-southeast-1"
}

provider "aws" {
    alias  = "mumbai"
    region = "ap-south-1"
}

provider "aws" {
    alias  = "usa"
    region = "us-east-1"
}
```

The alias name is arbitrary. It is a label used to reference that specific block from a
resource. Once the aliases exist, a resource points at one of them with the `provider`
argument, written as the provider type followed by a dot and the alias name, for example
`aws.mumbai` or `aws.usa`.

## Walkthrough

The demo file is `multi-provider-config.tf`, committed to the course GitHub repository. It
starts with a single provider block set to `ap-southeast-1` (Singapore) and two security
groups, `prod_firewall` and `staging_firewall`.

### Step 1: fix the duplicate resource name

`terraform validate` fails before anything else can happen:

```
Duplicate resource "aws_security_group" configuration
```

Both security group resources were written with the same local name. The names were changed
to `sg_1` and `sg_2`, and `terraform validate` passed.

### Step 2: apply with a single provider

```
terraform apply -auto-approve
```

Both security groups were created. Verified in the console under the Singapore region
(`ap-southeast-1`), security groups: `prod_firewall` and `staging_firewall` both present.

```
terraform destroy -auto-approve
```

### Step 3: show that a bare duplicate provider block is rejected

A second `provider "aws"` block was added with `region = "ap-south-1"` and no alias.
`terraform validate` failed:

```
Duplicate provider configuration
```

The error text itself points at `alias` as the way to do this legally.

### Step 4: add the aliases

`alias = "mumbai"` was added to the second block, and a third block was added with
`alias = "usa"` and `region = "us-east-1"`. `terraform validate` passed.

### Step 5: show that aliases alone change nothing

```
terraform apply -auto-approve
```

Both security groups still landed in `ap-southeast-1`. Confirmed in the console: both
`staging_firewall` and `prod_firewall` in the Singapore region. Defining an alias does not
move a resource. If a resource does not name a provider, it uses the default block, whatever
that happens to be.

```
terraform destroy -auto-approve
```

### Step 6: associate the resources with the providers

```
resource "aws_security_group" "sg_1" {
  name     = "prod_firewall"
  provider = aws.usa
}

resource "aws_security_group" "sg_2" {
  name     = "staging_firewall"
  provider = aws.mumbai
}
```

`terraform validate`, then `terraform apply -auto-approve`.

Verified in the console:

- Mumbai region (`ap-south-1`): `staging_firewall`
- Virginia region (`us-east-1`): `prod_firewall`

## Notes

- The `alias` argument goes on the provider block. The `provider` argument goes on the
  resource block. They are two separate steps and both are needed.
- The default provider block, the one without an alias, is what any resource that omits
  `provider` falls back to.
- From the exam perspective the video says a high level understanding is enough: know what
  the `alias` block allows you to do.