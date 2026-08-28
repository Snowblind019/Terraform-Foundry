# 31 Dynamic Blocks

Cutting down repeated nested blocks inside a single resource.

Files in this folder:

- `sg.tf`, the finished version using a dynamic block. The original repeated form is kept in comments at the bottom.

Docs referenced in the video: https://developer.hashicorp.com/terraform/language/expressions/dynamic-blocks

---

## The problem

A security group with five inbound rules means five `ingress` blocks, and every one of them is identical apart from the port number:

```hcl
ingress {
  from_port   = 8200
  to_port     = 8200
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
```

Five is annoying. Forty or fifty, which is normal in a real account, is not something I want to hand maintain. This is the DRY thing, don't repeat yourself.

Ran the repeated version first with `terraform plan` and `terraform apply -auto-approve` to confirm it works, then checked the AWS console. Security group `sample-sg` was there with all five inbound rules on 8200, 8201, 8300, 9200 and 9500.

## The variable

The dynamic block iterates over something, so the list of ports goes into a variable first:

```hcl
variable "sg_ports" {
  type    = list(number)
  default = [8200, 8201, 8300, 9200, 9500]
}
```

## The dynamic block

```hcl
dynamic "ingress" {
  for_each = var.sg_ports
  content {
    from_port   = ingress.value
    to_port     = ingress.value
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

Reading it back:

- The label after `dynamic` is the name of the nested block being generated, so `dynamic "ingress"` produces `ingress` blocks.
- `for_each` is what it walks over, in this case the list in the variable.
- `content` is the body of one generated block, written the same way I would write a single `ingress` block by hand.
- Inside `content`, the iterator is named after the block, so `ingress.value` is the current item from the list. The port number changes each pass, the protocol and CIDR do not, so those stay hardcoded.

Five list items, five `ingress` blocks at plan time. The file is short, what Terraform builds internally is the same thing the repeated version produced.

## The docs example

The example in the documentation looks slightly different:

```hcl
dynamic "setting" {
  for_each = var.settings
  content {
    namespace = setting.value["namespace"]
    name      = setting.value["name"]
    value     = setting.value["value"]
  }
}
```

Square brackets there because each item in that list is a map with several keys, so it has to pick one out. My list is just numbers, so `ingress.value` is the number itself and there is nothing to index into.

## Verifying

```sh
terraform destroy -auto-approve
terraform plan
terraform apply -auto-approve
```

Destroyed the old security group first so the new code built it from scratch rather than showing a diff. Plan came back clean, apply completed, and the console showed the same five inbound rules as before.

## When to use it

For repeated nested blocks inside one resource. `ingress` and `egress` rules are the obvious case. It is not for creating multiple copies of a resource, that is `count`, which was the earlier lab. This is about what goes on inside a single resource block.