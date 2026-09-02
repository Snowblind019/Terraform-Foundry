# 48 Implicit vs Explicit Dependencies

Two ways to define a dependency between resources. Explicit is the `depends_on` meta argument from the last video. Implicit is referencing one resource's attribute inside another, which Terraform picks up on its own.

Files in this folder:

- `implicit-dependency.tf`

Docs:

- https://developer.hashicorp.com/terraform/language/meta-arguments/depends_on
- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group

---

## Explicit dependency

This is what lab 47 covered. You add `depends_on` and give it the resource address of the thing that has to come first:

```hcl
depends_on = [aws_s3_bucket.example]
```

It gets used when there is no direct attribute reference between the two resources, so Terraform has no other way of knowing they are related.

## The requirement for this one

An EC2 instance that should only accept communication from a trusted set of IP addresses. Two resources:

- the EC2 instance
- the firewall, which in AWS is a security group

Doing it by hand, you create the security group with the rules for the trusted IPs first, then create the instance and associate it with that group.

## Why the base code has no dependency

```hcl
resource "aws_instance" "example" {
  ami           = "ami-0e449927258d45bc4"
  instance_type = "t2.micro"
}

resource "aws_security_group" "prod" {
  name = "production-sg"
}
```

Nothing connects these. Terraform will create them in parallel, and at this stage the order genuinely does not matter, because the instance is not associated with the group either way.

`depends_on = [aws_security_group.prod]` would force the group first. That works, but it only fixes the ordering. The instance still is not attached to the group.

## Implicit dependency

The `aws_instance` resource has an argument called `vpc_security_group_ids`. The docs describe it as a list of security group IDs to associate with, and every security group in AWS has an ID.

You could create `production-sg` first, look up its ID, and paste that ID in as a literal. That is not workable for production. You would be creating the group, fetching the ID, and hand editing the config every time.

Instead, reference the resource attribute directly:

```hcl
vpc_security_group_ids = [aws_security_group.prod.id]
```

`aws_security_group.prod` is the resource address, `.id` is the attribute. The `id` attribute is listed in the attribute reference section of the security group docs and holds the group's ID.

Terraform reads that, sees the instance needs the group's ID to be built, and works out the order itself. Security group first, fetch its ID, then create the instance with that value filled in.

## What plan and apply show

`terraform plan` shows `id` on the security group as known after apply, since the group does not exist yet, and `vpc_security_group_ids` on the instance as known after apply for the same reason. The value is not available until the group is created.

`terraform apply -auto-approve` creates the security group first, prints its ID, then creates the EC2 instance associated with that ID.

Checking afterwards in the console, the instance's security group is `production-sg` with an ID ending `3b8e`. The same ID appears in `terraform.tfstate` under the security group resource, and that is the value that got computed into `vpc_security_group_ids` on the instance.

## When implicit is not an option

Implicit dependency only works if there is an argument on one resource that takes a value from the other. `aws_instance` has `vpc_security_group_ids`, so a security group can be wired in implicitly.

An S3 bucket is the counterexample. If `aws_instance` has no argument that takes an S3 bucket value, there is nothing to reference, so there is no way to create an implicit dependency. That is where `depends_on` comes in, which is exactly the situation in lab 47.

In production, implicit dependencies get used heavily, and explicit ones where the requirement calls for it.

## Commands used

```sh
terraform apply -auto-approve

terraform destroy -auto-approve
```