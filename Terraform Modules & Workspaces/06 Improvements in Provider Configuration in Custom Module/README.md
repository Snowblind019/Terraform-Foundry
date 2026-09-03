# 06 Provider Improvements in a Module

Taking the hardcoded provider block out of the module and replacing it with a `required_providers` block.

Files in this folder:

- `main.tf`, the module code in `modules/ec2`
- `module.tf`, the calling code in `teams/A`

Docs:

- https://developer.hashicorp.com/terraform/language/providers/requirements
- https://registry.terraform.io/providers/hashicorp/aws/latest/docs

---

## Why the provider block comes out

Up to now the module has carried a hardcoded `provider "aws"` block. That is not the best practice and it gets removed here.

The reasoning given is about versions. Module code can end up working only with certain versions of the AWS provider plugin rather than all of them. Declaring which versions the code works with means that when someone runs `terraform init`, the provider that gets installed is one the code is known to work with, so they do not run into errors from an unexpected version.

That declaration is the `required_providers` block, which was covered in earlier videos.

## The module code

Remove the provider block from `modules/ec2/main.tf` and add this in its place:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.50"
    }
  }
}
```

`source` is `hashicorp/aws`, the official AWS provider plugin. It replaces whatever was in the example block that got copied in.

For the version, use whatever the code is currently working against. Two ways to check what that is:

- the `.terraform.lock.hcl` file, which showed 5.51 as the version that got installed on the earlier successful init
- the registry page, which showed 5.52.0 published three days earlier

Given that, `>= 5.50` covers it. Being more specific about the version also works. It depends on the requirement.

## Removing the region variable

The provider block in the module was the only thing using `var.region`, so the region variable goes too. Remove the declaration and the reference.

The calling code then loses its `region` argument as well, since the module no longer accepts one.

Instead, the region gets set with a provider block in the calling code:

```hcl
provider "aws" {
  region = "ap-south-1"
}
```

## The warning

```sh
terraform plan
```

Plan showed one to add, along with a warning that the aws provider was implicitly specified but listed in `required_providers` as mycloud.

The cause was the block that got copied in. The example uses `mycloud` as the local name for the provider, and only the `source` had been changed to `hashicorp/aws`. The local name was still mycloud.

Changing that key from mycloud to aws and running plan again cleared the warning. Plan then shows one to add with nothing else.

## Commands used

```sh
terraform plan
```