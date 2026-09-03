# 05 Adding Variables to a Module

The EC2 module so far has everything hardcoded, so every team calling it gets the same instance in the same region. This video replaces those hardcoded values with variables and shows the calling code passing its own values in.

Files in this folder:

- `main.tf`, the module code in `modules/ec2`
- `module.tf`, the calling code in `teams/A`

---

## Changing the module code

Open `modules/ec2/main.tf`. The base code has the AMI, the instance type and the region all written in directly. Each one gets swapped for a variable reference.

```hcl
provider "aws" {
  region = var.region
}

resource "aws_instance" "myec2" {
  ami           = var.ami
  instance_type = var.instance_type
}
```

Referencing a variable is not enough on its own. Each one also needs a declaration. Until they are declared, VS Code shows a red mark under the variable, which is the signal that something still has to be fixed.

```hcl
variable "ami" {}
variable "instance_type" {}
variable "region" {}
```

Adding the declaration clears the red mark. The declarations are being kept in the same file here to keep things simple. Putting them in a separate file is the recommended approach.

## The error

Back in the teams folder:

```sh
terraform init
terraform plan
```

Plan fails with missing required arguments. The three arguments it names are `ami`, `instance_type` and `region`, which are exactly the three variables just declared in the module.

The variables have no defaults, so the module has nothing to fall back on. The values have to come from somewhere, and that somewhere is the code calling the module.

## Passing values in

Open `teams/A/module.tf`. The provider block that had been declared there for ap-south-1 gets removed first, then the three values go inside the module block alongside the source.

```hcl
module "ec2" {
  source        = "../../modules/ec2"
  instance_type = "t2.micro"
  ami           = "ami-123"
  region        = "ap-south-1"
}
```

The AMI here is a made up value, ami-123, since the point is only to see whether the value passes through.

## Verifying

```sh
terraform plan
```

The plan shows the values that were set in the calling code, instance type t2.micro, AMI ami-123, and the instance going into ap-south-1. Checking the plan output against what was written in `module.tf` is how to confirm the values are being taken.

Changing `instance_type` to `t2.large` and running plan again confirms it. The plan now shows t2.large.

This is the advantage of variables in a module. The module code stays as it is, and each team calling it sets whatever values suit them.

## Commands used

```sh
terraform init

terraform plan
```