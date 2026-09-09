# 03 - Terraform Backends

Section 5: Remote State Management

## Documentation referenced

- https://developer.hashicorp.com/terraform/language/backend
- https://developer.hashicorp.com/terraform/language/backend/local

## What a backend is

The backend determines where Terraform stores its state file.

If you do not explicitly specify a backend in your configuration, Terraform uses the
default local backend, and that backend writes `terraform.tfstate` into the same project
folder as your configuration. Every lab in the course up to this point has been running
on the default local backend without saying so.

## Part 1: Confirming the default

The demo folder, `kplabs-terraform`, contained a single file, `sg.tf`, creating a
security group in AWS:

```hcl
resource "aws_security_group" "prod" {
  name = "production-sg"
}
```

No backend block anywhere in the folder. Applied with:

```sh
terraform apply -auto-approve
```

The security group was created, and `terraform.tfstate` appeared in the same folder
automatically. That state file holds the information about the resources Terraform has
created and manages.

## The collaboration problem with the local backend

Terraform projects are normally handled by a whole team. Keeping the state file on one
developer's laptop gets in the way of that.

Concretely: if another team member wants to add arguments to an existing resource or add
new resources, they need two things from you. They need `sg.tf`, and they need
`terraform.tfstate`. The code alone is not enough.

The recommended production architecture that follows from this has two halves:

1. Terraform code goes in a central Git repository, GitHub or Bitbucket or whatever the
   organization uses, so all team members have access.
2. The state file goes in a central backend, not the default local backend.

The state file does not stay on the local laptop and does not go into the Git repository
either. It goes to its own remote backend.

## Backends Terraform supports

The local backend is one of many. Backends named in the video:

- Consul
- S3, used quite extensively
- AzureRM, for organizations on Azure
- GCS, for organizations on Google Cloud
- Kubernetes

The configuration block differs per backend. The S3 backend takes different arguments than
the Kubernetes backend, and so on. The documentation page lists each one with its own
configuration example.

Which one an organization picks generally follows from which cloud provider they are on.

## Why this connects back to the previous video

The state file can contain sensitive information like passwords, which is why it should
not be committed to the Git repository. The instructor called this a big no from a
security point of view.

The positive version of that rule: the state file should live in a central backend such as
Consul or S3, where it can also be encrypted. That is the part a Git repo does not give
you.

## Part 2: Explicit local backend configuration

Even though the local backend is used by default, you can declare it explicitly and then
pass parameters to it. The one shown is `path`, which controls where the state file is
written. This is useful if you do not want `terraform.tfstate` sitting in the project
folder.

The instructor destroyed the existing security group first, then copied the local backend
snippet from the documentation. He mentioned he also adds these snippets to the course
GitHub repo in case the documentation changes.

```hcl
terraform {
  backend "local" {
    path = "prod.tfstate"
  }
}
```

### Where to put the block

He added it to `sg.tf` in the demo, but said that from a production perspective you should
not put the backend block in the same file as your resource definitions. It belongs in its
own file called `backend.tf`. From Terraform's point of view it makes no difference which
file it sits in. This is a practice, not a requirement.

### Running it

The old `terraform.tfstate` was deleted first. Then:

```sh
terraform init
terraform apply -auto-approve
```

`terraform init` is required here. Once you explicitly define a backend, you have to
re-initialize before applying.

After the apply, the state file in the project folder was named `prod.tfstate` instead of
`terraform.tfstate`, as set by the `path` argument. The instructor noted the file does not
have to be in the project folder at all; you can point it at a different folder.

## Two more points on remote backends

### Authentication

Accessing state in a remote service generally requires access credentials. If Terraform is
configured with an S3 backend and tries to write the state file there, S3 will ask it to
authenticate. Without authentication Terraform can neither push data to nor pull data from
the bucket. So you need a set of credentials with access to the appropriate S3 bucket, and
Terraform uses those credentials both to store the state file and to pull it back.

### State locking

Some backends behave like a plain remote disk for state files. Others support state
locking as well. This is not uniform across backends, so before choosing one for the
organization, read the description for that specific backend. The example given was Consul,
whose documentation states that it supports state locking.

## Commands used

```sh
terraform apply -auto-approve
terraform destroy -auto-approve
terraform init
```

## Note on the state file being deleted manually

Before switching to the explicit local backend, he deleted the old `terraform.tfstate`
file by hand after destroying the resource. That worked here because the resource was
already destroyed and the state was effectively empty. Nothing in the video covers what
happens if you delete a state file that still tracks live resources.