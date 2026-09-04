# 07 Module Outputs

Getting a value out of a module so another resource in the root module can use it.

Files in this folder:

- `main.tf`, the child module code in `modules/ec2`
- `module.tf`, the root module code in `teams/A`

Docs:

- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip

---

## Why this matters

In an organization there tend to be modules for a range of services and a number of projects using them. Cross project collaboration happens regularly, and passing values between them is what module outputs are for.

The concept is the same as the output values covered in the earlier section of the course. Project A defines an output, project B fetches the value. The only difference is that the code producing the output is a module rather than code written directly in the same place.

## The challenge

The root module calls the EC2 module and also creates an Elastic IP.

Child module:

```hcl
resource "aws_instance" "myec2" {
  ami           = "ami-08a0d1e16fc3f61ea"
  instance_type = "t2.micro"
}
```

Root module:

```hcl
provider "aws" {
  region = "us-east-1"
}

module "ec2" {
  source = "../../modules/ec2"
}

resource "aws_eip" "this" {
  domain = "vpc"
}
```

As written, this creates an EC2 instance and an Elastic IP but does not connect them. An Elastic IP that is not attached to anything has no value, and it gets charged for as well.

## What it looks like done by hand

Doing the same thing manually in the console to see it clearly. Launch an EC2 instance, that is what the module block produces. Then go to Elastic IPs and allocate a new one, that is the `aws_eip` resource. At this point they exist separately.

Associating the Elastic IP with the instance is the missing step. After associating, the Elastic IP ending in 136 shows up as the instance's public IP, also ending in 136.

## The argument that does it

The `aws_eip` resource has an `instance` argument that takes the instance ID, the same thing being picked in the console when associating.

The instance ID has to come from the module, so the reference starts with `module.ec2`. Looking at the attribute reference section of the `aws_instance` documentation, the attribute holding it is `id`, described as the ID of the instance.

The first attempt:

```hcl
resource "aws_eip" "this" {
  domain   = "vpc"
  instance = module.ec2.id
}
```

```sh
terraform validate
```

This fails. The error says this object does not have an attribute named id.

That is the point of the whole video. Attributes of resources inside a module are not reachable from outside it. Nothing comes out of a module unless the module publishes it.

## Adding the output

Add an output to the child module:

```hcl
output "instance_id" {
  value = aws_instance.myec2.id
}
```

Running validate again still errors, because the reference in the root module was still `module.ec2.id`. What comes out of a module is the output name, not the attribute name. The reference has to be `module.ec2.instance_id`.

```hcl
instance = module.ec2.instance_id
```

Validate succeeds after that change.

## Confirming end to end

```sh
terraform apply -auto-approve
```

Two resources get created, the EC2 instance and the EIP. In the console, the instance created by Terraform, the one with no name, has a public IP of 164.21, which matches the Elastic IP. That confirms the output worked and the association happened.

## The referencing pattern

With output values earlier in the course, the reference went straight at the resource, because everything was part of the same code.

With a module it is different:

```
module.<module name>.<output name>
```

The output values themselves work the same way. It is only the reference from the root module that takes this form.

## Commands used

```sh
terraform validate

terraform apply -auto-approve
```