# 01 Creating Firewall Rules using Terraform

First lab of the Read, Generate, Modify Configurations section. The goal was to build a security group in AWS through Terraform instead of clicking through the console.

**What I built:**

- A security group named `terraform-firewall`
- One inbound rule: allow TCP port 80 from `0.0.0.0/0`
- One outbound rule: allow all traffic to `0.0.0.0/0`

Docs I used: [aws_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)

---

## The thing I actually came away with: group and rules are separate resources

This is the whole point of the lecture. In AWS, a security group is a container and the rules live inside it. In Terraform those are two different resource types:

| What it is | Resource type |
|---|---|
| The group itself | `aws_security_group` |
| One inbound rule | `aws_vpc_security_group_ingress_rule` |
| One outbound rule | `aws_vpc_security_group_egress_rule` |

If I only write the `aws_security_group` block, I get a group with zero rules. It exists, it applies cleanly, and it does absolutely nothing. That is different from creating a group in the console, where AWS quietly attaches an allow-all outbound rule for me. Terraform gives me exactly what I asked for and nothing else, which is the correct behavior but easy to trip over.

The rule resources point back at the group with `security_group_id = aws_security_group.allow_tls.id`. That reference is doing two jobs at once: it tells AWS which group the rule belongs to, and it tells Terraform that the group must be created before the rules. That is an implicit dependency, and there's a whole lecture on it later in this section.

### One rule per resource

Each `aws_vpc_security_group_ingress_rule` block is exactly one rule: one CIDR, one protocol, one port range. If I want port 80 and port 443, that's two resource blocks. If I want port 80 from two different CIDRs, that's also two blocks. There's no way to pack a list into one rule resource.

That gets repetitive fast, which is exactly the problem `count` and `for_each` solve later in this section.

### Why not the old inline `ingress` / `egress` blocks

Older Terraform code puts `ingress { }` and `egress { }` blocks directly inside `aws_security_group`. That style still works but HashiCorp now steers people to the separate rule resources, and the two approaches **cannot be mixed on the same group**. If I define inline blocks and standalone rule resources against the same security group, they fight each other: on every apply, one will try to remove what the other just created. Pick one style per group and stay with it.

The standalone resources are better anyway. Because each rule is its own resource with its own address in state, `terraform plan` shows me a rule being added or removed as a discrete change instead of a giant diff on the group.

---

## ingress and egress

- **ingress = inbound**, traffic arriving at whatever the group is attached to
- **egress = outbound**, traffic leaving it

Same words CloudFormation uses, so this vocabulary is worth memorizing once and reusing everywhere.

---

## from_port and to_port are a range, not a direction

This confused me for a second because "from" and "to" sound like source and destination. They aren't. They're the two ends of a port range.

```hcl
from_port = 80
to_port   = 80    # a single port
```

```hcl
from_port = 80
to_port   = 100   # all 21 ports, 80 through 100 inclusive
```

The lecture demonstrates the range version to show what happens in the console, then leaves it applied. Worth changing back to `80`/`80` before moving on so the code matches the stated architecture.

---

## ip_protocol = "-1"

`-1` means all protocols. Otherwise it's `"tcp"`, `"udp"`, `"icmp"`, or a protocol number.

The important rule: **when `ip_protocol` is `-1`, I cannot set `from_port` or `to_port`.** All protocols implies all ports, so specifying a port range is contradictory and the provider rejects it. That's why the egress rule in this lab has no port arguments at all.

---

## Changing security_group_id destroys and recreates the rule

At the end of the lecture, the ingress rule's `security_group_id` is repointed at the default security group. The plan comes back as **1 to add, 1 to destroy**, not a modify.

That's because `security_group_id` is a force-new attribute. AWS has no API for moving an existing rule between groups, so Terraform's only option is to delete the rule from the old group and create an equivalent one in the new group. Any argument that can't be changed in place behaves this way, and `plan` will say so explicitly with a comment like `# forces replacement`.

Reading plan output for forced replacement versus in-place update is a habit worth building now. On a lab it's meaningless. On something like an RDS instance or an EC2 instance with local storage, "forces replacement" means data is about to disappear.

---

## Things I'd change if this were real

Since I want to end up doing cloud security, worth writing down what an auditor would flag here:

- **Port 80 open to `0.0.0.0/0`** is fine for a public web server, and it's the stated architecture for this lab. It's only a finding if the thing behind it isn't meant to be public. What *is* always a finding is management ports open to the world: SSH 22, RDP 3389, database ports. That's the single most common misconfiguration in AWS and it's a one-line change in this exact file.
- **Egress allow-all** is the AWS default and almost nobody restricts it, but restricting egress is real defense in depth. It's what stops a compromised instance from calling out to an attacker's server.
- **No `vpc_id`** means this landed in the default VPC. The default VPC has public subnets and an internet gateway already attached, which is convenient and also why it shouldn't be running anything I care about.
- **The local names are wrong.** `allow_tls` and `allow_tls_ipv6` came straight from the docs example. This group has nothing to do with TLS and the "ipv6" rule uses `cidr_ipv4`. Terraform doesn't care, but names that lie are worse than no names.

---

## Finding the right resource in the docs

The lecture's method, and it's a good one. Search for the resource type by the AWS service name, then check the argument reference for whether each argument is Required or Optional. `description` and `vpc_id` are both Optional here, which is why the group applies fine without them.

The second trick: if I know how to create something in the console, I basically know how to create it in Terraform, because the arguments map to the same fields the console asks for. Name, description, VPC, then rules.

Also worth noting that HashiCorp reorganizes these doc pages regularly. The security group page currently shows the rule resources in its examples, but that isn't guaranteed to stay. The rule resources have their own doc pages, and searching for the resource type directly is more reliable than following whatever the parent page happens to link today.

---

## Commands run

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

Cleanup:

```bash
terraform destroy -auto-approve
```