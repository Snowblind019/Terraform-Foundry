# 07 Terraform Variables

Two videos, theory then practical. Input variables, which are the way to keep values out of the main configuration file.

Docs referred to: [Input Variables](https://developer.hashicorp.com/terraform/language/values/variables)

Files in this folder:

- `terraform-variables.tf`, the security group and its three rules
- `variables.tf`, the variables those rules pull from

---

## The problem

Repeated static values in a large codebase cause problems.

The example: a VPN server IP that has to be allowed through the firewall on five different ports. That is the same IP address written five times. In a real organization it might be in hundreds of rules.

When the VPN server gets replaced and the IP changes, all of those have to be found and edited by hand. That takes time and it is easy to miss one or fat-finger one.

The base file here has a smaller version of the same thing, one security group with three rules for ports 8080, 22, and 21, and the same IP address typed out in all three.

## The fix

Put the value in one place and have the config point at it.

Define the variable:

```hcl
variable "vpn_ip" {
  default = "200.20.30.50/32"
}
```

Reference it:

```hcl
cidr_ipv4 = var.vpn_ip
```

`var` means this is a variable, and `vpn_ip` is the name. When Terraform runs a plan or apply, it goes and finds the variable with that name and drops the value in.

Now changing the IP is one edit in one file, and every rule using it updates on the next apply. I changed the value, ran apply, and all three rules in the console changed to the new address.

## Ports too

The video does the same thing with the ports, which are not repeated but are still values someone might need to change:

```hcl
from_port = var.app_port
to_port   = var.app_port
```

After swapping those in, `terraform plan` showed no changes. Makes sense, the values coming out of the variables are identical to what was hardcoded before. Nothing about the infrastructure changed, only where the config reads the numbers from.

The general rule from the video is to touch the main configuration file as little as possible. Anything likely to change should be a variable so it can be changed without editing the file where the resources are defined. Fewer edits to the core config means fewer chances to break something.

## Error when the variable file is not saved

Ran `terraform plan` and got:

```
Reference to an undeclared variable
```

The variable file had not been saved yet, so as far as Terraform was concerned `vpn_ip` did not exist. Saved it, ran plan again, worked.

## Name the file variables.tf

The video starts by calling the file `central-location.tf` to make the idea obvious, then renames it. `variables.tf` is the standard name.

Terraform does not care, it loads every `.tf` file in the folder regardless of name. The reason to follow the convention is so anyone else opening the folder knows where to look.

## The description argument

```hcl
variable "vpn_ip" {
  default     = "200.20.30.50/32"
  description = "This is a VPN Server Created in AWS"
}
```

Worth doing in anything real. Someone new to the codebase reading `vpn_ip` has no way to know which VPN server, or why it is allowed through. The description is the only place that gets explained.

## Other arguments exist

The docs page for variables lists more than `default` and `description`. There is `type`, `validation`, `sensitive`, `nullable`, and others. The course covers those later. For now, `default` and `description` are the two in use.

---

## Commands run

```bash
terraform plan
terraform apply -auto-approve
terraform destroy -auto-approve
```