# 17 Count Index

`count.index` is the attribute that goes with the `count` meta-argument. Every copy a resource block creates gets its own index number, starting at 0, and I can reference that number inside the block. That is what turns three identical copies into three copies that differ from each other.

Files in this folder:

- `count-index.tf`, the EC2 block with the indexed name tag, the fixed IAM user block, and the list variable version

---

## The index numbering

With `count = 3` the block creates three objects, and the indexes are 0, 1 and 2. Not 1, 2, 3. The addresses look like this:

```
aws_instance.myec2[0]
aws_instance.myec2[1]
aws_instance.myec2[2]
```

Those addresses show up in the plan and apply output, so I can read straight off the CLI which copy is being created or changed.

## Fixing the identical names

The last lab ended with all three instances tagged `payments-system`, which is not useful for telling them apart. Putting the index into the tag fixes it:

```hcl
tags = {
  Name = "payments-system-${count.index}"
}
```

The plan showed the tag changing on all three, `payments-system` to `payments-system-0`, then `-1`, then `-2`. After `terraform apply -auto-approve` the console showed three instances with three distinct names. There was also a destroy in that plan because I had temporarily removed the IAM user block while working through this, not related to the tag change itself.

The `${}` is needed because the index is being inserted into a piece of text.

## Fixing the IAM user failure

Last lab this block was the failure demo. Three copies, one hardcoded name, and IAM names are unique per account, so index 0 was created and 1 and 2 errored.

```hcl
resource "aws_iam_user" "this" {
  name  = "payments-user-${count.index}"
  count = 3
}
```

Same fix. Each copy now has its own name, so all three apply cleanly. The IAM console showed payments-user-0, payments-user-1 and payments-user-2.

## Supplying my own names from a list

Numbered names work but they are still generic. The more useful version is a list variable holding real names, with `count.index` used as the position to read from:

```hcl
variable "users" {
  type    = list
  default = ["alice", "bob", "johncorner", "james", "mrA"]
}

resource "aws_iam_user" "that" {
  name  = var.users[count.index]
  count = 3
}
```

Index 0 pulls alice, index 1 pulls bob, index 2 pulls johncorner. The plan showed those three names and the apply created them.

Error I hit on the way: I wrote the name the same way as the blocks above it, as a quoted string. That errored on plan. This one is a straight reference to a variable rather than text with a value dropped into it, so the quotes come off and it becomes `var.users[count.index]`. Plan ran fine after that.

## The list can be longer than the count

The list has five entries but `count = 3`, so only the first three are used. james and mrA are simply not read. Adding them and running `terraform plan` again showed no changes to the infrastructure. The count decides how many values get pulled, not the length of the list. Count of 2 would take the first two, and so on.

Destroy the resources at the end to avoid charges.