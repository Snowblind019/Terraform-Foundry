# 03 Creating Elastic IP with Terraform

Short one. The code block is tiny, and the reason it gets its own video is that Elastic IPs come up repeatedly later in the course.

Docs referred to: [aws_eip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip)

---

## What an Elastic IP is

A static public IPv4 address in AWS. You allocate it, and then you can associate it with an EC2 instance so the instance keeps the same public address. Without one, the public IP on an instance changes when it stops and starts.

Two steps in the console: allocate the address first, then associate it with an instance if you want to. Allocating it on its own is fine, it just sits there unattached.

## The code

```hcl
resource "aws_eip" "lb" {
  domain = "vpc"
}
```

That is the whole thing. `domain = "vpc"` is the only argument I need.

The example on the docs page also includes an `instance` argument, which is what attaches the EIP to an EC2 instance. The docs list it as optional, and I am only allocating the address with nothing to attach it to, so I removed it.

Checking whether an argument is Required or Optional on the docs page is the habit here. If it says optional, the resource will create fine without it.

## Verifying it worked

Two places to check after `apply`:

- The AWS console, on the Elastic IPs page, in whatever region the provider block points at
- The state file, which has the allocated IP address in it

The state file showing the address is worth noting. Terraform records what AWS actually gave back, not just what I asked for.

---

## Do not leave it sitting there

AWS charges for Elastic IPs that are allocated but not in use. This one is not attached to anything, so it is billing the whole time it exists.

`terraform destroy` releases it. Then check the console to confirm it is gone, since the whole point of checking is not trusting that it happened.

---

## Commands run

```bash
terraform plan
terraform apply -auto-approve
terraform destroy -auto-approve
```

No `terraform init` needed if the provider was already downloaded in this folder. Since I use a separate folder per lab, each one needs its own `init` the first time.
