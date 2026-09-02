# 54 Preconditions and Postconditions

Custom conditions attached to a resource. A precondition is checked before the object is evaluated, a postcondition after.

Files in this folder:

- `pre-condition.tf`

Docs:

- https://developer.hashicorp.com/terraform/language/expressions/custom-conditions
- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ec2_instance_type
- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance

---

## Preconditions

Checked before evaluating the object they are attached to. The example used here: launch an EC2 instance only if the instance type is free tier eligible.

The scenario is a common one. Give developers access and they will launch servers bigger than the application needs, and the bill goes up. A precondition on the instance stops that, returning an error rather than creating anything.

If the precondition fails, the launch never starts.

## Postconditions

Checked after evaluating the object. The instance gets created, then Terraform checks something about it, for example whether it has a public IP address, or whether the attached EBS volume is encrypted.

## Syntax

Both go inside a `lifecycle` block in the resource, and both take a `condition` and an `error_message`. The structure is the same as the input variable validation block from the last two labs.

```hcl
lifecycle {
  precondition {
    condition     = ...
    error_message = "..."
  }

  postcondition {
    condition     = ...
    error_message = "..."
  }
}
```

## The data source

```hcl
data "aws_ec2_instance_type" "example" {
  instance_type = "t2.micro"
}
```

`aws_ec2_instance_type` fetches the characteristics of a single instance type. AWS has a long list of instance types, and this data source returns the attributes for whichever one is named.

The attribute that matters here is `free_tier_eligible`. A new AWS account gets 750 hours of free EC2 usage on the right instance type, and `t2.micro` is one of those. The list changes over time, it could be `t3.micro` tomorrow, so check what AWS is currently showing as free tier eligible.

Testing it with a temporary output:

```hcl
output "instance_type" {
  value = data.aws_ec2_instance_type.example.free_tier_eligible
}
```

`terraform plan` with the instance type set to `t2.micro` returns true. Changing it to `m5.large` and planning again returns false.

## The precondition in use

The video pulls the instance type out into a variable so both the data source and the resource reference `var.instance_type` from one place. Without any condition on it, running plan and entering `m5.large` just accepts it and would launch an m5.large on apply. That is the thing to prevent.

```hcl
precondition {
  condition     = data.aws_ec2_instance_type.example.free_tier_eligible
  error_message = "Instance Type is not part of free tier"
}
```

No comparison operator needed. `free_tier_eligible` is already true or false, and true is what the condition wants. True means proceed, false means stop.

Running plan and entering `m5.large` fails with a resource precondition failed error, showing the value it computed as false. Entering `t2.micro` plans normally.

## The postcondition and self

```hcl
postcondition {
  condition     = self.public_ip != ""
  error_message = "EC2 must have public IP address"
}
```

`self` refers to the resource block the postcondition sits in, so `self.public_ip` instead of writing out `aws_instance.example.public_ip`.

`self` is only available in a postcondition. A precondition runs before the object is evaluated, so there are no attributes to read yet. That is the reason for the restriction.

`public_ip` is in the attribute reference section of the `aws_instance` docs. The condition asks whether it is not empty, which is true if an address was assigned and false if not.

Applying with `t2.micro` creates the instance, and checking the console confirms it has a public IP.

## Making the postcondition fail

Flipping the operator to `==` inverts it, so the condition now demands an empty public IP, which will not be the case.

Plan does not fail here. There is no way to know the instance's public IP before it exists. `terraform apply -auto-approve` creates the instance, and immediately after creation completes the error appears: resource postcondition failed, showing the actual IP against a condition expecting empty.

After that, plan fails too, because the postcondition is now failing on the existing resource. Destroy still works though. Terraform allows the resource to be torn down so the code can be fixed and reapplied.

## Points to remember

- `self` in a postcondition refers to the attributes of the resource under evaluation, and is only available there
- preconditions and postconditions need Terraform 1.2.0 or later
- they are supported on resources, and also on data sources and outputs

## Commands used

```sh
terraform init

terraform plan

terraform apply -auto-approve

terraform destroy -auto-approve
```