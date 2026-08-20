# 02 Dealing with Documentation Code

No new AWS concept here. This one is about the situation where the Terraform code in front of me doesn't match the documentation in front of me, and I need to work out whether the code is wrong or just older than the docs.

Docs referred to: [aws_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)

Two files in this folder so I can see both side by side:

- `old-approach-firewall.tf`, rules written as inline `ingress` and `egress` blocks
- `new-approach-firewall.tf`, rules written as separate resources

---

## The same security group, two ways

**Old approach:** one `aws_security_group` resource with `ingress` and `egress` blocks nested inside it.

**New approach:** an `aws_security_group` resource for the group, then `aws_vpc_security_group_ingress_rule` and `aws_vpc_security_group_egress_rule` resources for the rules.

Both create the same thing in AWS. The new one is what the documentation shows today and what HashiCorp recommends. The old one is what the documentation used to show.

The important part: the old code still works. I ran `terraform init` to pull the current provider, then applied the old-style file, and it created the security group with the 443 inbound rule and the egress rule exactly as written. No error, no deprecation warning. A newer recommended approach does not mean the older one stopped working.

## The arguments are named differently

Comparing my two files, it isn't just the structure that changed:

| Old (inline block) | New (rule resource) |
|---|---|
| `protocol` | `ip_protocol` |
| `cidr_blocks`, a list | `cidr_ipv4`, one value |
| `ipv6_cidr_blocks`, a list | `cidr_ipv6`, one value |

Allow-all outbound is also written differently in each:

- Old: `protocol = "-1"` with `from_port = 0` and `to_port = 0`
- New: `ip_protocol = "-1"` with no port arguments at all

Worth remembering, because seeing `protocol` instead of `ip_protocol` immediately tells me which era a piece of code came from.

---

## Reading the docs at an older provider version

This is the actual technique from the video. The registry docs let me pick a provider version, and the example usage changes to match what that version documented.

There's a version dropdown on the page, but the version is also just part of the URL:

```
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
https://registry.terraform.io/providers/hashicorp/aws/5.31.0/docs/resources/security_group
```

Switch to 5.31.0 and the example usage shows the inline `ingress` and `egress` style. Switch back to latest and it shows the separate rule resources.

So when I'm looking at inherited code that doesn't match the docs, the move is to find out what provider version it was written against and read the docs at that version. The code stops looking wrong.

---

## Why organizations don't just rewrite everything

The video's point, and it lines up with what I see at work: if the code works and the provider version is pinned, there's no reason to rewrite it because a docs example changed. Large codebases don't get refactored for style. The Windows 10 comparison in the video is the idea, if everything is working there's no need to change it just because something newer exists.

So an enterprise will pin a provider version, stay on it while it's doing the job, and keep whatever code style was current when it was written. Which is exactly why I'll run into old-style code and need to know how to read it.

---

## Thing that caught me out

The current docs example for the new approach references a VPC:

```hcl
vpc_id    = aws_vpc.main.id
cidr_ipv4 = aws_vpc.main.cidr_block
```

There's no `aws_vpc "main"` block in the example, so copying it as-is fails on plan with a reference to an undeclared resource. I added the VPC resource in my file so it actually runs. The `ipv6_cidr_block` reference also needs `assign_generated_ipv6_cidr_block = true` on the VPC, otherwise it's null and the IPv6 rules fail.

Docs examples are fragments, not complete configurations.

---

## Takeaways

- A recommended approach replacing an older one does not mean the older one stops working
- Argument names change between versions, not just structure
- The provider version is in the docs URL, use it to read the docs the original author was reading
- Nothing has to be memorized, all of it comes from the documentation

---

## Commands run

```bash
terraform init
terraform plan
terraform apply -auto-approve
terraform destroy -auto-approve
```