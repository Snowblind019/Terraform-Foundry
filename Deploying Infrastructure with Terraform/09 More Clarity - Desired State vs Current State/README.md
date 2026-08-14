# 09 - Defaults, and What Actually Counts as Desired State

Follow-on to section 08, and the part that corrects an assumption that's easy to walk away with.

## Minimal config, maximum guessing

This is the whole resource block that's been used since section 01:

```hcl
resource "aws_instance" "WinterdayEC2" {
  ami           = "ami-091124c3965bce679"
  instance_type = "t3.micro"
}
```

Two arguments. But a running EC2 instance is not two arguments' worth of thing. It has a root volume of some size and type, a security group, a subnet, a VPC, an availability zone, tenancy settings, metadata options, and a long list of other decisions that were made on your behalf.

Nobody made those decisions. AWS filled them in, because the API request arrived without them and defaults exist. You get an 8 GiB SSD root volume, the default security group in the default VPC, and a subnet picked for you.

The same is true of every provider. Azure and GCP do the same thing with their own defaults.

## Reading it off the plan

Run `plan` on that block and a lot of the output says `(known after apply)`. Subnet ID, security group IDs, private IP, ARN, volume ID. That's Terraform saying it has no value for the attribute and won't until AWS answers back.

That's the tell. Anything showing `(known after apply)` is a decision you haven't made.

## The important bit

**Defaults are not part of your desired state.**

Desired state is what's written in the config, and nothing else. AWS choosing an 8 GiB volume and the default security group doesn't add those choices to what you declared. They were never declared.

Which means if someone goes into the console and swaps the security group from `default` to something else, the next `terraform plan` says **No changes**. Not because Terraform didn't look, it refreshed and saw the new group perfectly well. It just has nothing in the config to compare it against, so there's no difference to report.

This trips people up because section 08 established "Terraform reverts manual changes," and here's a manual change it doesn't revert. Both are true. The rule is more precise than it first looked:

> Terraform enforces the attributes you declared. Everything else is left alone.

## Why that matters more than it sounds

Read that as a security statement rather than a syntax one and it gets uncomfortable.

If `vpc_security_group_ids` isn't in your config, then the firewall on that instance is unmanaged. It can be changed to anything by anyone with console access and Terraform will never flag it. Your repo looks like a complete description of the environment, and reviewing the repo tells you nothing about what's actually open on that box.

Same for the root volume, which by default has `delete_on_termination` set to true and no encryption specified. Same for `metadata_options`, where IMDSv2 enforcement lives.

Undeclared doesn't mean safe defaults. It means whatever the provider decided, and nobody reviewed it.

## The fix: declare what you care about

```hcl
resource "aws_instance" "WinterdayEC2" {
  ami                    = "ami-091124c3965bce679"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.web.id]

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }

  metadata_options {
    http_tokens = "required"
  }
}
```

Now all of that is desired state. Change the security group in the console and the next plan wants it back. Detach the encryption and the plan complains. The config has become an actual description of the instance instead of a rough sketch of one.

The general rule for production: explicitly set anything you'd care about if it changed, and let defaults cover only the things you genuinely don't mind about. The smaller the set of `(known after apply)` lines in your plan, the more of your infrastructure is actually under management.

Worth knowing that some of these force replacement rather than updating in place. Changing `subnet_id` rebuilds the instance. Changing `root_block_device.volume_size` upward is usually in-place, but changing `volume_type` may not be. Check the plan.

## The deliberate opposite

Sometimes you want an attribute set at creation and then never touched again, because something outside Terraform legitimately manages it afterwards. Autoscaling adjusting a desired count is the classic case. That's what `lifecycle` is for:

```hcl
resource "aws_instance" "WinterdayEC2" {
  # ...

  lifecycle {
    ignore_changes = [tags["LastPatched"]]
  }
}
```

This is the intentional version of what defaults do accidentally. The difference is that it's written down, so the next person reading the config knows the omission was a choice.

## Files

- `main.tf` - both versions, the minimal one and the explicit one, so the plan output can be compared.
