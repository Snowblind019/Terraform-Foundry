# 02 Dealing with Documentation Code

No new AWS concept here. This video is about what to do when the Terraform code you are looking at does not match the documentation, and you need to figure out if the code is wrong or just older than the docs.

Docs referred to: [aws_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)

Two files in this folder so I can compare both:

- `old-approach-firewall.tf`, rules written as inline `ingress` and `egress` blocks
- `new-approach-firewall.tf`, rules written as separate resources

---

## The same security group, two ways

**Old approach:** one `aws_security_group` resource with `ingress` and `egress` blocks inside it.

**New approach:** an `aws_security_group` resource for the group, then `aws_vpc_security_group_ingress_rule` and `aws_vpc_security_group_egress_rule` resources for the rules.

Both create the same thing in AWS. The new one is what the documentation shows now and what HashiCorp recommends. The old one is what the documentation used to show.

The main point of the video is that the old code still works. I ran `terraform init` to pull the current provider, applied the old style file, and it created the security group with the 443 inbound rule and the egress rule exactly as written. No error, no deprecation warning. A newer recommended approach does not mean the older one stopped working.

## The arguments are named differently

Comparing my two files, the structure is not the only thing that changed:

| Old (inline block) | New (rule resource) |
|---|---|
| `protocol` | `ip_protocol` |
| `cidr_blocks`, a list | `cidr_ipv4`, one value |
| `ipv6_cidr_blocks`, a list | `cidr_ipv6`, one value |

Allow all outbound is written differently in each one:

- Old: `protocol = "-1"` with `from_port = 0` and `to_port = 0`
- New: `ip_protocol = "-1"` with no port arguments at all

If I see `protocol` instead of `ip_protocol`, that tells me right away which version the code was written for.

---

## Reading the docs at an older provider version

This is the useful part of the video. The registry docs let you pick a provider version, and the example usage changes to match what that version showed.

There is a version dropdown on the page, and the version is also part of the URL:

```
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
https://registry.terraform.io/providers/hashicorp/aws/5.31.0/docs/resources/security_group
```

At 5.31.0 the example shows the inline `ingress` and `egress` style. Back on latest it shows the separate rule resources.

So if I am looking at old code that does not match the docs, I find out what provider version it was written against and read the docs at that version instead.

---

## Why companies do not just rewrite everything

If the code works and the provider version is pinned, there is no reason to rewrite it because a docs example changed. The video uses Windows 10 as the comparison, if everything you run works fine there is no reason to switch to 11 just because it exists.

Same with Terraform. A company will pin a provider version, stay on it while it does the job, and keep whatever code style was current when it was written. That is why I will keep running into old style code and need to be able to read it.

---

## Problem with the docs example

The current example for the new approach references a VPC:

```hcl
vpc_id    = aws_vpc.main.id
cidr_ipv4 = aws_vpc.main.cidr_block
```

There is no `aws_vpc "main"` block in the example, so copying it as is fails on plan with a reference to an undeclared resource. I added the VPC resource in my file so it runs. The `ipv6_cidr_block` reference also needs `assign_generated_ipv6_cidr_block = true` on the VPC or it comes back null and the IPv6 rules fail.

The docs examples are fragments, not complete configurations.

---

## Takeaways

- A newer recommended approach does not mean the older one stops working
- Argument names change between versions, not just the structure
- The provider version is in the docs URL, use it to read the docs the original author was reading
- Nothing needs to be memorized, all of it comes from the documentation

---

## Commands run

```bash
terraform init
terraform plan
terraform apply -auto-approve
terraform destroy -auto-approve
```