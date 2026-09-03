# 03 Module Sources

How to point at a module, wherever it happens to be stored.

Files in this folder:

- `modules.tf`

Docs:

- https://developer.hashicorp.com/terraform/language/modules/sources

Repository referenced in the video:

- https://github.com/zealvora/sample-kplabs-terraform-ec2-module

---

## Where module code can live

The source code for a module can sit in a wide variety of places:

- a GitHub page, which is common for the modules on the Terraform registry
- HTTP URLs
- S3 buckets
- the Terraform registry itself
- a local path on my own workstation or laptop

Bitbucket and generic Git repositories are on the list too.

## How a module gets referenced

Referencing is done with a `module` block, and inside that block there must be a `source` argument holding the location of the module.

```hcl
module "ec2" {
  source = "<path to the module>"
}
```

The `module` block and the `source` argument stay the same no matter where the code lives. What changes is the format of the value in `source`, which depends on the type of location it points at.

A local path looks like this, `../` followed by the path to the module source:

```hcl
module "ec2" {
  source = "../modules/ec2"
}
```

A generic Git repository has its own format, GitHub has another, Bitbucket another, S3 uses an `s3::` prefix, and so on.

## How to know which format to use

The documentation. The module sources page lists every supported source type, local paths, the Terraform registry, GitHub, Bitbucket, generic Git, HTTP URLs, S3, and gives the exact syntax for each one. That page is the reference whenever a new source type comes up.

## The practical

Back in the `kplabs-terraform` folder, which is empty, create a file called `modules.tf`.

The module being referenced is on GitHub, so the GitHub syntax gets copied out of the documentation and the path swapped for the real repository. The block name was changed to `ec2`.

```hcl
module "ec2" {
  source = "github.com/zealvora/sample-kplabs-terraform-ec2-module"
}
```

The repository contains a single `main.tf`, nothing complicated.

## The error on init

```sh
terraform init
```

This failed immediately with an error downloading, no source URL was returned.

The cause was the source value. It had `https://` on the front of it. The GitHub format in the documentation starts at `github.com`, with no scheme in front. Removing the `https://` and saving fixes it.

The general approach when a source fails is to go back and check the exact format the documentation gives for that source type.

Running init again worked. It installed the AWS provider plugin and the initialization completed.

```sh
terraform plan
```

Plan then showed the EC2 instance being created, coming from the code inside the module.

## Module versions

A module can have multiple versions published. To pin one, add a `version` argument alongside `source`.

```hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.8.0"
}
```

The EKS module on the registry has a long list of versions available. Selecting version 18.8.0 on the registry page changes the version argument in the sample code to match, and using that value pulls the code as it was written for that version rather than the latest code.

This one is called out as something to remember from the exam point of view.

## Commands used

```sh
terraform init

terraform plan
```