# 04 Referencing a Local Module from a Team Folder

Third step in building my own module. The base structure came first, then the EC2 module itself, and this one covers how a team member actually calls that module.

Files in this folder:

- `module.tf`

Docs:

- https://developer.hashicorp.com/terraform/language/modules/sources

---

## Picking the right source type

The module code and the team's code are both on the same workstation. So of all the source types available, GitHub, HTTP URL, S3 bucket and the rest, the one that applies here is the local path.

The documentation shows the local path format, and it states that a local path must begin with `./` or `../`. The example on that page uses `./consul`.

## What ../ is doing

The folder layout at this point:

```
kplabs-terraform-modules/
  modules/
    ec2/
      main.tf
  teams/
    A/
      module.tf
```

`module.tf` is being written inside `teams/A`, and it needs to point at `modules/ec2`.

The `..` in a path is the same `..` as on the command line. Running `cd ..` from `teams/A` moves back one directory to `teams`. Running `cd ..` again moves back another, to `kplabs-terraform-modules`.

That is the path being built up in the source argument:

- `../` from `A` lands in `teams`. The module code is not there.
- `../../` lands in `kplabs-terraform-modules`. This folder has `modules` in it.
- `../../modules` then `../../modules/ec2` reaches the module.

## The code

Create `module.tf` inside `teams/A`, either by copying the base example from the documentation or writing it out. The block is named `ec2`.

```hcl
module "ec2" {
  source = "../../modules/ec2"
}
```

## Running it

From `teams/A`:

```sh
terraform init
```

No error this time. Init initializes the `ec2` module and installs the hashicorp/aws provider plugin, and completes successfully.

```sh
terraform plan
```

Plan shows one EC2 instance being created, a t2.micro using the AMI defined inside the module.

## Applying the same pattern elsewhere

If team B needed to reference a security group module, the structure would be the same. A `module` block in their own folder, a local path source walking back up to `modules` and down into the right module folder.

## Commands used

```sh
terraform init

terraform plan
```