# 38 Larger Infrastructure and API Throttling

What goes wrong once a Terraform project gets big enough that a single operation makes hundreds of calls to the provider, and the three ways the video deals with it.

Files in this folder:

- `larger-infra.tf`

Docs:

- https://docs.aws.amazon.com/general/latest/gr/aws_service_limits.html
- https://developer.hashicorp.com/terraform/cli/commands/plan
- https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest

---

## Cloud does not mean unlimited

Using AWS, GCP or Azure does not mean unlimited resources. Every provider applies limits per service. In AWS these are the service quotas. Some quotas sit at the account level, and the quota page tells you whether each one is adjustable or not. For some you can raise the limit by asking AWS support. For others the adjustability column says non-adjustable and that is the end of it.

## API throttling

Separate from the resource quotas, each provider allows a certain number of API calls. Say AWS allows 10,000. Make 10,010 and the extra ten get throttled. You get an error back and the call does not go through.

On small or medium infrastructure this never comes up. On large infrastructure it is a real problem, and it is something you have to design around rather than discover at runtime.

## Why Terraform makes so many calls

If one project holds a large set of resources, a single `terraform plan` turns into a lot of API calls, because plan refreshes state before it does anything else. It goes out and asks the provider about every resource in the state file.

That is the part worth sitting with. Even when everything is already created and nothing is changing, a plan still hits the API once per resource. So on an account that is already close to its API limit, running a plan on a large project can throttle the production applications running in that same account.

The example from the video is a hardening project. CIS benchmark as the base plus custom rules, four or five documents worth of rules, all built in Terraform. Hundreds of rules means hundreds of resources means a plan or apply that could not safely be run against one or two specific accounts, because those accounts were already at their throttling limit and running it would have taken production down.

## The practical

`larger-infra.tf` uses the `terraform-aws-modules/vpc/aws` module. On the surface it is a short file, but the module expands into a lot of resources behind the scenes.

```sh
terraform init
terraform plan
```

Plan came back with around 35 resources to add. VPC, public and private subnets across three AZs, route tables, NAT gateway, VPN gateway, plus the security group and its two rules from the bottom of the file.

```sh
terraform apply -auto-approve
```

Took around two to three minutes because of the number of resources.

Then, with everything already built:

```sh
terraform plan
```

The output scrolls through refreshing state for the security group and every resource in the VPC module. Nothing is changing, and it still walks the whole list. Scale that to hundreds of resources and that is the API call volume that causes the problem.

Note on cost: the module creates a NAT gateway and a VPN gateway, both of which are billed. Do not leave this one running.

## Solution 1, split the project

Instead of one project holding everything, split it into separate folders. One for VPC, one for IAM, one for EC2 and security groups, and so on.

A plan in the VPC folder only refreshes VPC resources. The IAM and EC2 resources live in a different project with a different state file, so no calls are made for them at all. Same total infrastructure, but the calls are spread across separate operations instead of fired all at once.

## Solution 2, resource targeting

If splitting the project is not an option right now, use the `-target` flag and work one resource at a time. Create the EC2 instance, then the security group, then IAM, and so on.

```sh
terraform plan -target aws_security_group.allow_tls
```

Fewer calls per operation. This is the same flag from lab 37, used here for a different reason.

## Solution 3, refresh=false

The third option is to skip the refresh step:

```sh
terraform plan -refresh=false
```

To show the difference I added a second security group, `allow_tls2`, to the file. A normal `terraform plan` refreshed every existing resource first, then reported the one new resource to add. With `-refresh=false` there is no explicit refresh, so the plan runs off what is already in the state file. It comes back faster, and the API calls that the refresh would have made never happen.

## When not to use refresh=false

The video is clear that this is not the default for a reason. Refresh is on by default because Terraform cannot otherwise know whether the state file still matches the real infrastructure. If something was changed outside Terraform, a plan with `-refresh=false` will not see it.

Use it when you are confident the state file is in sync with the real world and the API limits leave you no other option. Otherwise run the normal operation.