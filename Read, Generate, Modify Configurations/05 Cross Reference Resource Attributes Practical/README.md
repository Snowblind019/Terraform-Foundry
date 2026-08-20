# 05 Cross Reference Resource Attributes

Two videos, theory then practical. Covers referencing an attribute of one resource inside another resource. This is the thing that gets used constantly in real Terraform code.

Docs referred to:
- [aws_eip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip)
- [aws_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)
- [aws_vpc_security_group_ingress_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule)

---

## The problem

A file can have 2 resources or it can have 20, and often one of them needs a value that comes from another one.

The example here: allocate an Elastic IP, then create a security group rule that allows port 443 from that Elastic IP. The IP does not exist until AWS hands it out, so there is nothing to type into the rule when I am writing the config.

The obvious workaround is to create the EIP first, copy the address AWS gave me, and paste it into the security group. That works once. It is not the right way, because the config only matches reality until something changes and I have to remember to update it by hand.

What I want is for the security group rule to pull the value from the Elastic IP automatically, after the EIP exists.

## The syntax

```
resource_type.local_name.attribute
```

So for the public IP of the EIP in this file:

```hcl
aws_eip.lb.public_ip
```

`aws_eip` is the resource type, `lb` is the local name I gave it, `public_ip` is the attribute. The Attribute Reference section on the docs page is where I confirm `public_ip` is a thing the resource actually exposes.

## There are two cross references in this file

The Elastic IP one is the obvious one. The second is `security_group_id`:

```hcl
security_group_id = aws_security_group.example.id
```

Same situation. The rule has to attach to a security group, `security_group_id` is required, and AWS does not give out the `sg-` ID until the group exists. So it gets referenced off the `id` attribute instead of being pasted in.

One thing to watch when copying from the docs: the security group example uses the local name `allow_tls`, and the rule example references `aws_security_group.example.id`. Those do not match. One of them has to be renamed or it will not resolve. I renamed the group to `example`.

## Terraform works out the order on its own

Watching the apply output, the resources come up in this order:

1. Elastic IP
2. Security group
3. Security group ingress rule

Nothing in the file says to do it in that order. Terraform sees that the rule references the other two, so it knows those have to exist first.

---

## The practical, and the part that actually failed

`terraform plan` came back clean, 3 to add. Then `terraform apply` failed on the third resource.

**Lesson: a successful plan does not mean a successful apply.** Plan checks the configuration. It cannot know whether AWS will accept every value, because some of those values do not exist yet at plan time.

The error:

```
Invalid Attribute Value
attribute cidr_ipv4 value must be a valid IPv4 CIDR block that represents a network address
```

and it printed the value it got, which was the bare Elastic IP address with no prefix on it.

### Half the infrastructure existed

The Elastic IP was created. The security group was created. The rule failed. So the account was left with a security group that had no rules in it.

That is normal Terraform behavior, it applies what it can and stops where it breaks, but it is worth knowing what that looks like since it is what a real failed deploy looks like too.

### Why it failed

`cidr_ipv4` wants a CIDR block, not a bare IP address. AWS itself enforces this, the console will not let you save a rule with just an address either, it makes you write `/32` for a single host or `/24`, `/16`, and so on for a range.

So `35.154.233.58` is rejected and `35.154.233.58/32` is what it needs.

### Why writing it out did not work either

Adding `/32` after the reference is not something Terraform will just do:

```hcl
cidr_ipv4 = aws_eip.lb.public_ip/32
```

That fails. The value has to be computed first, then have `/32` appended to it, then get passed to the argument. That needs string interpolation:

```hcl
cidr_ipv4 = "${aws_eip.lb.public_ip}/32"
```

Everything inside `${ }` is a placeholder. Terraform works out the value, drops it in, and the rest of the string stays as written. So the final value becomes the address followed by `/32`.

After that change the apply succeeded, and the inbound rule in `attribute-sg` showed the Elastic IP with `/32` on the end.

### When you need `${ }` and when you do not

`security_group_id = aws_security_group.example.id` has no interpolation and works fine. That value is also computed by Terraform, so the difference is not whether the value is known ahead of time.

The difference is whether the attribute is the entire value or part of a larger string. On its own, write it bare. Glued to other text like `/32`, it has to go inside `${ }` in a string.

### Clean up the half-applied state

The video's point at the end: running apply two or three times until it works is not an infrastructure problem, but it is not how it should be left. After fixing the error, destroy everything and apply again so the whole thing builds in one pass. That confirms the config is actually correct rather than just eventually working.

---

## Commands run

```bash
terraform plan
terraform apply -auto-approve
terraform destroy -auto-approve
terraform apply -auto-approve
```