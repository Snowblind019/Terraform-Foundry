# 23 Overview of Data Sources

A data source lets Terraform read information that is defined outside of Terraform. Not things Terraform created and tracks, but whatever already exists: an account, a file on the workstation, instances someone else launched. It shows up constantly in production code because it is what makes configuration flexible instead of hardcoded.

Files in this folder:

- `data-source-01.tf`, reading a DigitalOcean account
- `data-source-02.tf`, reading a local file, plus an output block
- `demo.txt`, the file being read
- `data-source-03.tf`, reading EC2 instances in a region

Docs:

- https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/data-sources/account
- https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file
- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance

---

## How it fits together

The data block fetches information from somewhere outside the configuration. That information then gets handed to a resource block, or an output block, which does something with it. The data block on its own does not build anything.

The block is `data`, then the type of information wanted, then a local name:

```hcl
data "digitalocean_account" "example" {}
```

The local name is arbitrary, same as with resources. It is what other blocks use to reference the data.

## Example 1: DigitalOcean account

Used here as a second provider so the concept is not tied to AWS. DigitalOcean is not an official provider, so it needs a `required_providers` block, and the provider block takes the account token.

The data block itself is a single line with an empty body. `terraform init`, then `terraform apply -auto-approve`.

Two things stand out in the output. First, the CLI says Reading, then Read complete after 1s. That reading is the fetching of information from outside Terraform, which is the whole idea. Second, the apply completes with no resources created. A data source does not create anything.

So where did the information go. `terraform.tfstate`. Everything fetched is written there, and looking in the state file shows the account email, whether it is verified, the droplet and floating IP limits, the account status. The same fields the documentation page for that data source lists.

## Example 2: local file

```hcl
data "local_file" "foo" {
  filename = "${path.module}/demo.txt"
}
```

Reads a file from the local file system. `demo.txt` was created alongside it with a line of text in it. `terraform init` again for the local provider, then apply.

Same behaviour, it reads, creates nothing, and the contents end up in the state file under the `local_file` entry.

To get it out of the state file and onto the screen:

```hcl
output "data" {
  value = data.local_file.foo.content
}
```

`content` is the attribute holding what was read. Applying again prints the file contents to the CLI. That is the first bit of passing data out of a data block into something else.

### path.module

`path.module` returns the file system path where the code is located. Without it the filename would have to be a full path like C:\Users\zealv\kplabs-terraform\demo.txt, which is long and breaks the moment the code moves. `path.module` resolves to the directory the expression is being loaded from, so Terraform works the path out on its own.

## Example 3: EC2 instances in a region

```hcl
provider "aws" {
  region = "us-east-1"
}

data "aws_instances" "example" {}
```

AWS has many regions, and this fetches instances from whichever one the provider is set to, so the region matters.

First apply, the read completed but the state file entry was empty. Nothing wrong with the code, there were simply no instances running in that region. After launching two instances manually and applying again, the state file showed both instance IDs, matching what the console showed, along with private and public IP addresses and a few other details.

## The thing to take forward

Everything so far only fetches. The point of fetching is what comes next: passing the data to a resource block so it can create or modify infrastructure based on values that were never written into the code. Fetched private IPs feeding into something that acts on those instances, for example. That comes later in the course. For now the concept is what matters, data sources read, resources build.

## Working notes

Each example was run on its own. To keep the previous file out of the way, it was renamed to `.bak`, since Terraform only loads files ending in `.tf`. Each new provider needs its own `terraform init` before the apply will work.