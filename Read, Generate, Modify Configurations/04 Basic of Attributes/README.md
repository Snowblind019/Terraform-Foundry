# 04 Basic of Attributes

First video on attributes. Kept simple here, the course comes back to them in more detail later.

Docs referred to:
- [aws_eip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip)
- [aws_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance)

---

## What an attribute is

An attribute is a field on a resource that holds a value, and that value ends up in the state file.

Easier to see with an example. After an EC2 instance is created, it has attributes like:

| Attribute | Value |
|---|---|
| `id` | the instance ID AWS assigned |
| `public_ip` | the public IP of the instance |
| `private_ip` | the private IP |
| `private_dns` | the internal DNS name |

None of those are things I put in the config. They are values AWS produced when it built the resource, and Terraform saved them into `terraform.tfstate`.

## Arguments vs attributes on the docs page

Every resource page in the registry has both sections, and they are different things:

- **Argument Reference** is what I can set in the config. `ami`, `instance_type`, `domain`.
- **Attribute Reference** is what comes back after the resource exists. `id`, `arn`, `public_ip`, `instance_state`.

The Attribute Reference section also describes what each one is, so that is the place to look when I need to know what a resource exposes.

## Looking at them in the state file

I applied the EIP and the EC2 instance, then opened `terraform.tfstate`.

Each resource in there has its type and name at the top, `aws_eip` named `lb` and `aws_instance` named `web`, and further down an attributes section with everything Terraform recorded.

For the EIP, `public_ip` is in there. For the instance, `id` and `public_ip` are both in there. I checked both against the AWS console and they matched.

That is the practical part of this video. If I want to know the public IP of something Terraform built, I do not have to open the console, it is already sitting in the state file.

Attributes get used constantly once resources start referencing each other, which is what the next few videos cover.

---

## Commands run

```bash
terraform apply -auto-approve
terraform destroy -auto-approve
```
