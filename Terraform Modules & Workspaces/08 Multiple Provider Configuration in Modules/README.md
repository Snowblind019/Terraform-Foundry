# 08 Multiple Provider Configurations in a Module

Getting two resources inside the same child module to be created in two different regions.

Files in this folder:

- `sg.tf`, the child module code in `modules/network`
- `main.tf`, the root module

---

## The default behavior

Everything so far has relied on inheritance. The root module has a provider block, the child module has none, and every resource in the child module picks up the root's provider configuration.

```
kplabs-terraform/
  main.tf
  modules/
    network/
      sg.tf
```

`sg.tf` holds two security groups, dev and prod:

```hcl
resource "aws_security_group" "dev" {
  name = "dev-sg"
}

resource "aws_security_group" "prod" {
  name = "prod-sg"
}
```

`main.tf` calls the module and sets the provider:

```hcl
provider "aws" {
  region = "us-east-1"
}

module "sg" {
  source = "./modules/network"
}
```

```sh
terraform init
terraform plan
terraform apply -auto-approve
```

Plan shows two security groups. After apply, both dev-sg and prod-sg appear in North Virginia. Neither resource specifies a provider, so both inherited the root configuration.

## The requirement

In production there are cases where different resource blocks inside one module need different provider configurations. Here, prod-sg should be created in Mumbai while dev-sg stays in North Virginia.

Specifying a provider block at the root module does not solve this on its own.

## Aliased providers are not inherited

Add a second instance of the AWS provider with an alias:

```hcl
provider "aws" {
  alias  = "mumbai"
  region = "ap-south-1"
}
```

After destroying and recreating, the state file still shows both resources in us-east-1. The alias by itself changes nothing.

Trying to use it directly from the child module by putting `provider = aws.mumbai` on the prod resource fails at plan time, with an error saying the provider configuration is not present. Terraform cannot find it, because it was never passed into the child module.

The default provider configuration gets inherited automatically. A provider configuration with an alias set never does.

## The three steps

### 1. Pass the provider into the module

In the module block in the root, add a `providers` map:

```hcl
module "sg" {
  source = "./modules/network"
  providers = {
    aws.prod = aws.mumbai
  }
}
```

This reads as `aws.mumbai` from the root being passed into the child module under the name `aws.prod`. The name on the left is whatever the child module expects, and can be changed to suit.

### 2. Declare the configuration alias in the child module

The child module has to say it accepts that provider. Inside the terraform settings block, in `required_providers`, add `configuration_aliases`:

```hcl
terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 5.0"
      configuration_aliases = [aws.prod]
    }
  }
}
```

The `required_providers` block itself comes straight from the documentation. The name in `configuration_aliases` has to match the name used on the left side of the providers map.

### 3. Use the provider meta argument on the resource

```hcl
resource "aws_security_group" "prod" {
  name     = "prod-sg"
  provider = aws.prod
}
```

The same name again. Since `aws.prod` is bound to `aws.mumbai`, this resource gets created in Mumbai. The dev resource has no provider argument, so it keeps inheriting the default and stays in us-east-1.

## Verifying

```sh
terraform destroy -auto-approve
terraform validate
terraform apply -auto-approve
```

The state file shows one resource in us-east-1 and the other in ap-south-1. In the console, dev-sg is in North Virginia and prod-sg is in Mumbai.

## Two points to remember

The `providers` argument in a module block is similar to the `provider` argument on a resource, but the module version is a map rather than a single string. The reason is that a module can contain resources from many different providers, so it needs key value pairs, and more than one pair can be passed.

Provider configurations with the `alias` argument set are never inherited automatically by a child module. They always have to be passed explicitly through the providers map in the root module.

## Commands used

```sh
terraform init

terraform plan

terraform apply -auto-approve

terraform destroy -auto-approve

terraform validate
```