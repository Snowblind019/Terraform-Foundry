# Terraform Foundry

Terraform labs and configurations I'm writing while learning the tool from scratch and working toward the HashiCorp Certified: Terraform Associate (004).

I work as a NOC analyst and I'm moving toward cloud security engineering. Terraform is how infrastructure gets built and reviewed at that level, so the goal here is to be able to write it from a blank file, not just read someone else's.

This repo is the learning record. It starts small and grows as I work through the material.

## Source material

- Zeal Vora, HashiCorp Certified: Terraform Associate (Udemy)
- The official HashiCorp Terraform documentation and 004 exam objectives

## Layout

Each lab is a self-contained folder with its own configuration. Nothing depends on anything outside its own directory.

```
.
└── labs/
    └── 01-first-resource/
        └── main.tf
```

## Running a lab

```bash
cd labs/01-first-resource
terraform init
terraform plan
terraform apply
terraform destroy
```

## Labs

| Lab | Topic | Status |
|---|---|---|
| 01 | First resource | in progress |

## Conventions

- Every lab uses local state. Remote backends come later, once the course covers them.
- I tear down each lab with `terraform destroy` when I'm done with it, so nothing sits running and accruing cost.
- State files and `.tfvars` are gitignored. State can hold secrets in plaintext, so it never gets committed.
- The provider lock file `.terraform.lock.hcl` is committed on purpose. It pins provider versions and is part of how Terraform is meant to be used.

## Environment

- Terraform 1.12.x
- AWS provider, us-west-2
- Fedora