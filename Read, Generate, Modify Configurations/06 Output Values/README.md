# 06 Output Values

Getting information about what Terraform built printed on the command line instead of digging for it in the console.

Docs referred to: [aws_eip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip)

---

## The problem

Applied a config that allocates an Elastic IP. It worked, but the CLI does not tell me what address I got. To find it I have to log into the console, switch to the right region, open Elastic IPs, and copy it from there.

That is slow, and there is no reason for it. Terraform already knows the address, it is sitting in the state file.

## The output block

```hcl
output "public-ip" {
  value = aws_eip.lb.public_ip
}
```

`public-ip` is just a name I picked, it is the label that shows up on the CLI. `value` is what gets printed, and here it is an attribute reference, same syntax as the last section.

So knowing the attributes matters again. I checked the Attribute Reference on the `aws_eip` page to confirm `public_ip` is what holds the address. That page also lists `public_dns` and others, so whichever one I want is the one I put here.

Run `terraform apply` again and the address prints at the end.

## Customizing the value

The value does not have to be the bare attribute. Applications often run on a specific port, so instead of an IP I can output a full URL:

```hcl
output "public-ip" {
  value = "https://${aws_eip.lb.public_ip}:8080"
}
```

Now the apply prints something I can copy straight into a browser. Same `${ }` rule as before, the attribute is inside a larger string so it needs interpolation.

## Leaving the attribute off

```hcl
output "public-ip" {
  value = aws_eip.lb
}
```

No attribute on the end, so it prints the whole resource. Every attribute it has, `public_ip`, `public_dns`, all of it.

Useful when I am not sure what a resource exposes and want to see everything at once.

## Outputs are stored in the state file

After the apply, `terraform.tfstate` has an outputs section with `public-ip` in it and the value underneath.

That matters because outputs are not only for printing to the screen. A separate Terraform project, in a different folder or a different repo entirely, can read the outputs out of this project's state file. So if project A creates the Elastic IP and project B needs that address, project B pulls it from A's outputs rather than having it hardcoded.

The course covers how that actually works later. For now the point is outputs are how one Terraform project exposes values to another.

---

## Commands run

```bash
terraform apply -auto-approve
terraform destroy -auto-approve
```