# 24 Data Sources - Format

The previous video showed data sources fetching information from DigitalOcean, a local file and AWS. This one answers the obvious follow up: how do I know what a data source can actually fetch for a given provider. The answer is the documentation.

Files in this folder:

- `data-source-format.tf`, reading an existing EC2 instance by tag

Docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/instance

---

## How provider docs are laid out

Every provider page in the registry splits into two sections that matter here:

- Resources, blocks that create something in the provider
- Data Sources, blocks that read something that already exists

That split is consistent across providers. AWS, Azure and GCP all have it. Within a provider the pages are grouped by service, so AWS has EC2, and under EC2 there is a resources list and a data sources list.

## Same name, opposite job

The clearest example is `aws_ami`, which exists in both sections.

- Resource `aws_ami`, creates an AMI
- Data source `aws_ami`, looks up an AMI that already exists and returns its ID

Same name, and the only thing separating them is which block type it is used in. That is the pattern to have in mind when reading someone else's code, `resource "aws_ami"` and `data "aws_ami"` are doing opposite things.

## The workflow

Pick the provider, find the service, open the Data Sources section for it, and read the page for the specific data source. The page lists the arguments it accepts and the attributes it returns, which is what tells you whether it can fetch what you need.

## The example file

```hcl
data "aws_instance" "example" {
  filter {
    name   = "tag:Team"
    values = ["Production"]
  }
}
```

`aws_instance` here is singular, which is a different data source from `aws_instances` used in the previous lab. Singular reads back a single instance, so it needs something to narrow the search down to one, which is what the `filter` block does. This one matches on the tag Team having the value Production.

Worth being careful with, since the two names are one character apart and return different shapes of data.