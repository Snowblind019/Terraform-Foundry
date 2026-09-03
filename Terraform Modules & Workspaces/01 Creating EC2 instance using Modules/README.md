# 01 Using a Ready Made Module

The first practical on modules. The requirement is an EC2 instance and the security group that goes with it, built without writing any of the resource code by hand. Instead of writing `aws_instance` and `aws_security_group` blocks, the whole thing comes from a module someone else already published.

Files in this folder:

- `ec2.tf`

Docs:

- https://registry.terraform.io/modules/terraform-aws-modules/ec2-instance/aws/latest

---

## Finding a module

Modules live at registry.terraform.io, under the Browse Modules option. There are a lot of them and each one covers a specific use case. For AWS alone there are modules for KMS, for VPC, and so on.

Searching for EC2 in the registry returns results under both Providers and Modules, so the Modules tab is the one to switch to. There were 33 pages of EC2 related modules, published by different people.

Anyone can publish to the registry, including me if I wanted to. That is the reason not to trust every module there by default. When I am not sure about one, the safer choice is the most popular module available.

The other way to find them, which is quicker, is to search Google for something like `terraform ec2 module`. The registry page comes back as a top result anyway.

## Checking whether a module is worth using

Download counts are the first signal. The EC2 instance module by terraform-aws-modules showed 32 million downloads over time. For comparison, the IAM module from the same publisher showed 104 million downloads this year and 298 million over time. Numbers like that show how heavily organizations actually use modules, which is why the topic matters.

The registry page links to the module's GitHub source. Things to look at there:

- the usage examples further down the page, which cover a single EC2 instance, multiple instances, and spot instances
- how extensive the documentation is
- the contributor count, 48 on this one, which suggests issues get looked at

The same examples also appear on the registry page itself, pulled directly from GitHub, so going to GitHub is optional.

## Using the module

The registry page has a Provision Instructions panel. That panel gives the module block to copy, which goes straight into a new `ec2.tf` in an otherwise empty folder.

```hcl
module "ec2-instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "6.1.4"
}
```

Two arguments to note:

`source` is the path to the module, `terraform-aws-modules/ec2-instance/aws`. It matches the URL of the registry page.

`version` pins which version of the module to use. A module can have several published versions.

None of the code that actually creates the EC2 instance or the security group is written in this file. It all comes from the module.

## terraform init

```sh
terraform init
```

Init does two things here. It initializes the backend as normal, and it initializes the modules, which means downloading the module code from registry.terraform.io to the local folder. Nothing can be built until that download happens.

## The plan error

```sh
terraform plan
```

The first plan failed. More than one subnet matched, and the error asked for additional constraints to narrow it down to a single subnet.

The fix is to specify which subnet the instance should launch into, using the `subnet_id` argument shown in the module's usage instructions.

To find a subnet ID, go to VPC in the AWS console, open the default VPC, and look at the subnets attached to it. Any of them will do for this lab. Copy the ID and put it in the module block.

```hcl
subnet_id = "subnet-03f8c90a72ead2e4d"
```

This behavior is specific to this module and this version. A module can be written so that the default VPC and a subnet get picked up automatically, in which case nothing needs hardcoding. It depends on the module.

## The successful plan and apply

With the subnet in place, plan ran clean and showed four resources to create:

- the EC2 instance
- the security group
- the rules associated with that security group

```sh
terraform apply -auto-approve
```

After the apply, the EC2 console showed one instance, with the security group attached to it. That security group already had outbound rules on it, created automatically by the module. None of that was written by hand.

## Where the module code actually lives

The downloaded code sits in the `.terraform` folder, in the same place the providers go. Inside it there is a `modules` folder, and inside that, `ec2-instance`.

Opening the module's `main.tf` shows 835 lines. That size is the point. Modules published to the registry tend to be mature, and they do far more than create one instance. The same module can create multiple instances, or a spot instance, among other things.

## Cleanup

```sh
terraform destroy -auto-approve
```

Run this at the end so the instance does not keep running and generating charges.

## Why this topic matters beyond the lab

Modules come up as a common question in Terraform interviews. They also appear on the Terraform professional certification, which is a four hour practical exam, as a scenario based question that has to actually be solved rather than recognized.

## Commands used

```sh
terraform init

terraform plan

terraform apply -auto-approve

terraform destroy -auto-approve
```