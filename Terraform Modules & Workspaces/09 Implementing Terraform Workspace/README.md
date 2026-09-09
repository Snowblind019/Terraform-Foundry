# 09 Terraform Workspaces

Using workspaces to deploy the same code into more than one environment, and changing the values it uses based on which workspace is active.

Files in this folder:

- `workspace.tf`

---

## The base code

```hcl
resource "aws_instance" "myec2" {
  ami           = "ami-08a0d1e16fc3f61ea"
  instance_type = "t2.micro"
}
```

The AMI ID is for the North Virginia region. Using a different region means changing it.

## The workspace subcommands

Running `terraform workspace` on its own lists the subcommands available for creating and managing workspaces.

```sh
terraform workspace
```

`show` gives the workspace currently in use:

```sh
terraform workspace show
```

Starting out, that is `default`.

`new` creates a workspace, and it also switches to it straight away:

```sh
terraform workspace new dev
terraform workspace new prod
```

After creating prod, the current workspace is prod.

`list` shows every workspace that exists, with a star next to the current one:

```sh
terraform workspace list
```

That gives default, dev and prod, with the star on prod.

`select` switches to an existing workspace:

```sh
terraform workspace select dev
```

## Why the base code is not enough

Running `terraform plan` in dev gives one EC2 instance at t2.micro. Switching to prod and running plan again gives the same thing, one instance at t2.micro. The instance type is hardcoded so the workspace makes no difference to it.

That is not what is wanted. In development a small instance is fine, there is no need for the CPU and RAM. In production a larger instance type is needed for the memory and CPU.

## Using a map

Each workspace needs its own value for instance type. Of the available types, number, bool, list, set, map and so on, a map is the fit, since it holds multiple key value pairs.

```hcl
locals {
  instance_type = {
    default = "t2.nano"
    dev     = "t2.micro"
    prod    = "m5.large"
  }
}
```

The keys match the workspace names.

Then the resource has to pull from it:

```hcl
instance_type = local.instance_type[terraform.workspace]
```

`terraform.workspace` gives the name of the current workspace. That name is used as the key into the map, so whichever workspace is active decides which value comes back.

## Verifying

With prod selected, plan shows m5.large. Confirming with `terraform workspace list` shows the star on prod.

Switching to dev and running plan again shows t2.micro.

## Where the state goes

Using workspaces creates a folder called `terraform.tfstate.d`. Inside it there is a subfolder per workspace, dev for the dev workspace and its data, prod for prod.

There is no subfolder for default. Code runs in the default workspace unless switched, and its `terraform.tfstate` file sits in the same folder as the code, as normal.

## Commands used

```sh
terraform workspace

terraform workspace show

terraform workspace new dev

terraform workspace new prod

terraform workspace list

terraform workspace select dev

terraform plan
```