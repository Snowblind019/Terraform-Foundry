# 06 - Terraform State Management

Section 5: Remote State Management

## Documentation referenced

- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule

## Why this exists

As Terraform usage gets more advanced, there are cases where the state file has to be
modified. The state file is one of the most important parts of a Terraform project, and
when people edit it by hand, mistakes happen. A severe enough mistake corrupts the state.

So the rule is: do not modify the state file manually.

That leaves two questions. If not by hand, then how? And what are the cases where you
would need to change state at all, given that none of the labs so far have required it?

The answer to the first is the `terraform state` subcommands, which HashiCorp provides
as the supported alternative. The subcommands covered here are `list`, `show`, `pull`,
`rm`, `mv`, and `replace-provider`.

## Setup

The file used creates an IAM user and a security group, with state stored in an S3 backend
rather than locally.

```hcl
terraform {
  backend "s3" {
    bucket = "kplabs-terraform-backends"
    key    = "demo.tfstate"
    region = "us-east-1"
  }
}

resource "aws_iam_user" "dev" {
  name = "kplabs-user-01"
}

resource "aws_security_group" "prod" {
  name = "terraform-firewalls"
}
```

The bucket name has to be changed to one you own, since S3 bucket names are unique across
all AWS accounts. The instructor demonstrated creating a fresh bucket in the console, using
`kplabs-sample-bucket-demo-001` as an example name, and said to paste whatever name you end
up with into the backend block.

```sh
terraform init
terraform apply -auto-approve
```

Both resources were created. The `kplabs-terraform` folder showed no state file locally,
confirmed by refreshing it. Opening the S3 bucket showed `demo.tfstate` sitting there.

## 1. terraform state list

Lists the resources that are part of the state.

```sh
terraform state list
```

Output was the two resources: `aws_iam_user.dev` and `aws_security_group.prod`.

This is useful for quickly seeing everything Terraform manages. A real project can have
hundreds of resources, and reading the configuration files to work that out is slower than
just listing state.

## 2. terraform state show

Shows the attributes of a single resource in state. Takes the resource address.

```sh
terraform state show aws_security_group.prod
```

The output listed all attributes on that resource: ARN, description, security group ID,
owner ID, the VPC ID it was created in, and the rest.

You could get the same information by opening the state file directly, but that is the
habit this whole video is arguing against. Opening the file is how people modify it by
accident.

The instructor also contrasted this with what people commonly do to find something like a
security group ID: log into the AWS console, go to EC2, find the security group, open it,
and read the ID off the page. `state show` gets you there faster.

## 3. terraform state pull

Pulls the state from the remote backend and writes it to stdout.

```sh
terraform state pull
```

Most organizations do not keep state locally, so if you want to look at current state you
otherwise have to go through the backend. The instructor walked through the manual version:
open the S3 console, find the bucket, find the state file, download it, open it. And if a
team member has changed it since, you do that again.

`terraform state pull` replaces all of that. It printed the full state file to the terminal.

## 4. terraform state rm

Removes an item from the state file.

### The use case

A resource has been modified manually so many times that reconciling it back to your
Terraform code is impractical. You want Terraform to stop managing it, but you do not want
Terraform to destroy it. Removing it from state achieves exactly that: Terraform will
neither modify nor destroy it, because as far as Terraform is concerned it no longer exists.

### Building up the scenario

The security group had no inbound or outbound rules, so two ingress rules were added to the
configuration:

```hcl
resource "aws_vpc_security_group_ingress_rule" "example" {
  security_group_id = aws_security_group.prod.id

  cidr_ipv4   = "10.0.0.0/8"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_vpc_security_group_ingress_rule" "example2" {
  security_group_id = aws_security_group.prod.id

  cidr_ipv4   = "10.0.0.0/8"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}
```

He noted two things while writing these: point `security_group_id` at `aws_security_group.prod.id`,
and give the second block a different local name from the first.

```sh
terraform plan
terraform apply -auto-approve
```

The plan showed two rules to create. After the apply, the AWS console showed two security
group rules on the `terraform-firewalls` security group.

### Simulating drift

He then edited one of those rules by hand in the console, changing the CIDR from
`10.0.0.0/8` to `0.0.0.0/0`, adding a description, and saving.

```sh
terraform plan
```

The plan showed two changes: remove the `0.0.0.0/0` rule and add back the `10.0.0.0/8`
rule from the configuration. Terraform pulling the resource back to what the code says.

This is a trivial amount of drift. The point is that in a real environment a resource may
have been changed twenty or thirty times, and at that stage you either reconcile your
configuration and state against reality, or you decide this resource is no longer worth
managing through Terraform.

### Why deleting the config is not the answer

If you take the second option and simply delete the resource blocks from the `.tf` file,
`terraform plan` shows Terraform trying to destroy the resources. Same for the security
group itself: remove its block and Terraform will destroy the security group in AWS.

That is the opposite of what you want. You want the security group to keep existing in
AWS, just not be managed by Terraform any more.

### Doing it properly

The blocks were put back, then removed from state instead:

```sh
terraform state pull
```

Run from a second tab first, to see what was in state: both ingress rules and the security
group.

```sh
terraform state rm aws_security_group.prod
terraform state rm aws_vpc_security_group_ingress_rule.example
terraform state rm aws_vpc_security_group_ingress_rule.example2
```

Each one reported the resource as removed.

```sh
terraform plan
```

The plan now showed Terraform trying to **create** all three resources. They are still in
the configuration but no longer in state, so Terraform treats them as new. It has no idea
they already exist in AWS.

At that point it is safe to delete the lines from the `.tf` file. After deleting them:

```sh
terraform plan
```

No changes. The resources are gone from Terraform entirely, and still live in AWS.

```sh
terraform state pull
```

Confirmed it: only the IAM user remained under resources, no security group resources at all.

The ordering matters here. Remove from state first, then remove from the configuration.
Doing it the other way around destroys the resources.

## 5. terraform state mv

Moves an item in state to a different address.

### The use case

Changing the local name of a resource in your configuration. The instructor changed the
IAM user's local name from `dev` to `prod`:

```sh
terraform plan
```

Terraform showed a destroy and a recreate. Only the local name changed, but Terraform reads
the new address as a different resource and the old address as gone.

For an IAM user that is inconvenient. For servers it is unacceptable, because destroying and
recreating loses the data on them.

### The fix

```sh
terraform state mv aws_iam_user.dev aws_iam_user.prod
```

Old address first, new address second. Once state has been moved, change the name in the
configuration to `prod` and save.

```sh
terraform plan
```

No changes, as expected.

## 6. terraform state replace-provider

Replaces the provider for resources in state.

### Where the provider lives in state

```sh
terraform state pull
```

The state file has a provider section, showing the AWS provider under the HashiCorp
namespace at `registry.terraform.io`.

### The use case

An organization may have built its own custom provider, for example a modified version of
the AWS provider, and want their resources pointed at that instead of the official one.

```sh
terraform state replace-provider hashicorp/aws kplabs.in/internal/aws
```

Current provider first, new provider second.

The command asks for confirmation before doing anything, showing the current provider in
state, the new provider address, and which resources are affected. Answering yes reported
that the provider was successfully replaced for one resource.

Before running it, the instructor pulled the state to a second tab as a backup, on the
grounds that messing this up can break the project.

### What went wrong, deliberately

```sh
terraform state pull
```

Confirmed the provider had changed to `kplabs.in/internal/aws` in state.

That provider does not actually exist, so:

```sh
terraform plan
```

failed with an error about failing to load plugin schemas.

### Reverting

```sh
terraform state replace-provider kplabs.in/internal/aws hashicorp/aws
```

Confirmed with yes, then `terraform plan` worked normally again.

## Commands used

```sh
terraform init
terraform apply -auto-approve
terraform plan
terraform state list
terraform state show aws_security_group.prod
terraform state pull
terraform state rm aws_security_group.prod
terraform state rm aws_vpc_security_group_ingress_rule.example
terraform state rm aws_vpc_security_group_ingress_rule.example2
terraform state mv aws_iam_user.dev aws_iam_user.prod
terraform state replace-provider hashicorp/aws kplabs.in/internal/aws
```

## Cleanup note

The video does not run a destroy at the end. By this point the security group and both
ingress rules have been removed from state, so `terraform destroy` would not touch them
anyway. They have to be deleted by hand in the console, which is the direct consequence of
using `state rm`.