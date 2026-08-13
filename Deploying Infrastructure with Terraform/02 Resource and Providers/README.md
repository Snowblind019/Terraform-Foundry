# 02 - Providers and Resources

Section 1 got a box running. This one is about what's actually happening underneath.

## A provider is a plugin

That's the whole thing. Terraform core doesn't know what AWS is. It doesn't know what an EC2 instance is. All it knows how to do is read config, build a dependency graph, and work out the difference between what you asked for and what exists. Every bit of "how do I actually talk to this API" lives in a provider plugin.

Which is why `terraform init` exists. When you add a provider block, init goes out to the registry, downloads the matching plugin, and drops it into a `.terraform` folder next to your code:

```
.terraform/providers/registry.terraform.io/hashicorp/aws/<version>/...
```

Go look in there once. The AWS plugin is around 300 MB. The Azure one is around 180 MB. That's the entire AWS API surface compiled into a binary, which is why it takes a minute the first time and why `.terraform/` is in the gitignore.

The registry (registry.terraform.io) has north of 3000 providers now. AWS, Azure, GCP, Alibaba, Kubernetes, GitHub, Cloudflare, and a very long tail after that.

## You can mix providers in one folder

Nothing stops you having AWS and Azure declared in the same directory. Add an `azurerm` provider block, run `init` again, and you'll see both plugins sitting in `.terraform/providers`. Terraform handles them side by side.

The rule is just that **each resource type is owned by exactly one provider.** `aws_instance` can only be handled by the AWS plugin. `azurerm_kubernetes_fleet_manager` can only be handled by the Azure plugin. If you declare only the Azure provider and then write an `aws_instance` resource, it won't work, because the plugin that knows how to create that thing was never downloaded.

Any time you add a new provider, run `init` again. That's the trigger for it.

## Resource type vs local name, again

```hcl
resource "aws_instance" "WinterdayEC2" { ... }
#          ^ type          ^ local name
```

The **type** is fixed by the provider. The **local name** is yours.

Together they form the identifier Terraform uses for that resource, and **that pair has to be unique inside the configuration.** Two `aws_instance` blocks both called `WinterdayEC2` will fail at plan time with an error about the name already being declared. Rename one and it's fine.

I want to correct something I wrote in my earlier notes here: the uniqueness requirement is per resource type **within your Terraform configuration**, not "unique on the AWS account." AWS has no idea this name exists. It's purely a Terraform-side label. You could have the exact same local name in a totally separate directory with its own state file and nothing would complain.

Adding a second instance is just another block:

```hcl
resource "aws_instance" "WinterdayEC2" {
  ami           = "ami-091124c3965bce679"
  instance_type = "t3.micro"
}

resource "aws_instance" "SnowydayEC2" {
  ami           = "ami-091124c3965bce679"
  instance_type = "t3.micro"
}
```

Same type, different local names, and they can have completely different AMIs and sizes if you want. There's no loop or count here yet, you just list them out. (There are better ways to do this once `count` and `for_each` show up later in the course, but the manual version is worth writing at least once.)

## Do I have to relearn Terraform per provider

No, and this is the part that actually sells it. The core syntax, the block structure, the init / plan / apply loop, state, variables, modules, all of that is identical no matter what you're pointing it at. What changes is the vocabulary: which resource types exist and what arguments they take. That's a docs lookup, not a relearn.

The prerequisite is knowing the platform itself. If you can't create an Azure VM by hand and explain what a resource group is, writing the Terraform for it isn't going to go well, because you won't know what the fields mean. Terraform is the wrapper, not the substitute.

## When the provider itself is wrong

Officially maintained doesn't mean bug free. Every provider has a GitHub repo with open issues and pull requests, and if you hit behaviour that doesn't match the docs, that's where it goes. With the AWS provider pulling tens of millions of downloads a month you're unlikely to be first, so check existing issues before opening one.

## Files

- `main.tf` - two instances, plus the second provider declared to show the plugin download.
