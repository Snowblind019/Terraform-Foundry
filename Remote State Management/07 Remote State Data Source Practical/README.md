# 07 - Remote State Data Source (Practical)

Section 5: Remote State Management

## Documentation referenced

- https://developer.hashicorp.com/terraform/language/state/remote-state-data
- https://developer.hashicorp.com/terraform/language/settings/backends/s3

## What this video covers

This is the practical follow-up to the previous video on what the remote state data source
gives you: one team reading output values out of another team's state file, without either
team sharing configuration.

The scenario is a networking team that owns an elastic IP, and a security team that needs
to whitelist that IP in a security group rule. The security team does not create the EIP
and does not hardcode it. They read it out of the networking team's state.

## Workflow

1. Create two folders, one per team
2. Networking team: create an EIP, store state in S3, expose the EIP as an output
3. Security team: use the `terraform_remote_state` data source to connect to the
   networking team's state file
4. Security team: use the fetched EIP in a security group rule

Both folders sit inside `kplabs-terraform`, named `networking-team` and `security-team`.

## Part 1: Networking team

### eip.tf

```hcl
resource "aws_eip" "lb" {
  domain = "vpc"
}

output "eip_addr" {
  value = aws_eip.lb.public_ip
}
```

The output block is the load-bearing part. The remote state data source can only read
output values, so anything the other team needs has to be declared as an output here.

### The bucket

Without a backend block, applying this would write `terraform.tfstate` locally, which
defeats the point. An S3 bucket is needed.

The instructor created a new one called `kplabs-networking-bucket-demo` in `us-east-1`.
An existing bucket works too. The name has to be unique across all of S3, so this exact
name will not be available to you.

### backend.tf

```hcl
terraform {
  backend "s3" {
    bucket = ""
    key    = "eip.tfstate"
    region = "us-east-1"
  }
}
```

Copied from the S3 backend documentation. The `key` is `eip.tfstate`, stored at the root of
the bucket. If the bucket had folders you could path into them here. The region has to match
where the bucket was actually created, `us-east-1` in this case.

### Running it

```sh
terraform init
terraform plan
terraform apply -auto-approve
```

The EIP was created, and because of the output block the apply printed the IP address:
`44.195.111.26`.

Refreshing the S3 bucket showed a new file, `eip.tfstate`. Opening it showed the output
section containing the EIP value. The instructor noted that the console's open option moves
around, and if opening in place is not available you can download the file and open it
locally.

The same IP was visible in the EC2 console under Elastic IPs.

## Part 2: Security team

### sg.tf, starting version

```hcl
resource "aws_security_group" "allow_tls" {
  name = "allow_tls"
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "172.31.20.30/32"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}
```

A security group with one inbound rule allowing `172.31.20.30/32` on port 443. That
hardcoded CIDR is the placeholder to be replaced. What the security team wants is the IP
the networking team created, computed automatically.

### How the data source works

The `terraform_remote_state` data source fetches output values from a state backend. Two
steps:

1. Define the remote state source: which backend the state lives in, and where inside that
   backend. This definition goes in the security team's configuration, not the networking
   team's.
2. Reference it with `data.terraform_remote_state.<name>.outputs.<output_name>`.

### data.tf

The documentation snippet was copied in and then modified, because the default example is
not for S3.

```hcl
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "kplabs-networking-bucket-demo"
    key    = "eip.tfstate"
    region = "us-east-1"
  }
}
```

`backend` was changed to `s3`, then the `config` block was filled from the networking team's
`backend.tf`: the same bucket, key, and region. The instructor copied those three lines
across directly, and removed an extra curly brace left over from the paste.

The security team is now declaring where to read from: this bucket, this state file.

### sg.tf, final version

```hcl
resource "aws_security_group" "allow_tls" {
  name = "allow_tls"
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "${data.terraform_remote_state.vpc.outputs.eip_addr}/32"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}
```

The reference breaks down as `data`, then `terraform_remote_state`, then `vpc` which is the
local name of the data block, then `outputs`, then `eip_addr` which is the name of the output
declared by the networking team.

The `/32` is appended with interpolation because AWS expects a CIDR range, and the output is
a bare IP address. Whatever value gets computed has `/32` stuck on the end.

### Running it

```sh
terraform init
terraform validate
terraform plan
```

The instructor ran `terraform validate` before planning, on the grounds that there can be
mistakes in this kind of configuration. It passed.

The plan showed `cidr_ipv4` resolved to `44.195.111.26`, matching the EIP the networking
team created. That is the confirmation that the remote state read worked: the value was not
in the security team's configuration anywhere.

## Commands used

```sh
terraform init
terraform plan
terraform apply -auto-approve
terraform validate
```

## Note on where the video stops

The security team side ends at `terraform plan`. The video confirms the IP resolved
correctly and concludes there, without running an apply on the security-team folder. So the
security group and its rule are never actually created.