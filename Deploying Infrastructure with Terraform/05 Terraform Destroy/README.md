# 05 - Destroying Resources

Tearing things down matters as much as building them, especially in a lab account where a forgotten instance quietly bills you all month.

## Destroy everything

```bash
terraform destroy
```

This targets everything in the current directory's state, not everything in your AWS account. That distinction matters. Terraform only ever touches what it knows it created, so anything you clicked together by hand in the console is untouched.

It prints a plan first and waits for a `yes`, same as apply.

## Destroy one thing

```bash
terraform destroy -target aws_instance.SnowydayEC2
```

The address after `-target` is `resource_type.local_name`, with a dot between them. So if I have both `WinterdayEC2` and `SnowydayEC2` declared and I only want to kill the second one, that's `aws_instance.SnowydayEC2`.

**It's case sensitive.** It has to match exactly what's written in the code, capital letters and all. `aws_instance.snowydayec2` will not resolve.

Worth knowing that `-target` is meant as an escape hatch rather than a daily driver. It skips over the dependency graph, so if the thing you're targeting has other resources hanging off it, you can end up with state that doesn't match reality. Fine for labs, use sparingly on anything real.

## Commenting a resource out

If you'd rather not create something without deleting the code, comment it out. Terraform sees it as no longer declared and will plan to destroy it on the next apply, same as if you'd deleted the block.

```hcl
# single line comment

/*
resource "aws_instance" "SnowydayEC2" {
  ami           = "ami-091124c3965bce679"
  instance_type = "t3.micro"
}
*/
```

`#` is the normal single line comment. `//` also works. `/* */` is the block comment for wrapping a whole resource.

Be clear on what's happening though: commenting out a block that has already been applied doesn't just stop managing it, it queues it for deletion. If you actually want Terraform to forget about a resource without destroying it, that's `terraform state rm`, which is a different thing entirely.

## Habits worth keeping

- Run `plan` before `apply` on anything that isn't a lab. It's the only free look you get.
- Run `destroy` at the end of every lab session. Free tier is only free while you're inside it.
- Read the plan output properly. The counts at the bottom (`x to add, y to change, z to destroy`) are the summary, but the actual danger is usually in a line further up that says a resource must be replaced.
