# 21 Challenge - Analyzing Terraform Code Containing Functions

No new material in this one. It sets up a challenge: read a block of code that uses several functions and work out what it will build, before running anything. The solution is video 22.

Files in this folder:

- `functions-challenge.tf`, the challenge code

---

## The task

1. Work out what the code does without running `terraform apply`. Once it is applied the functions have already done their job and the answer is sitting in the console, which skips the actual learning.
2. Use `terraform console` to test each function on its own and see what it returns. The docs are fair game too.
3. Write down what each function does and what the code as a whole will create.
4. Then run it and check whether the result matches what was written down.

## What is in the code

The provider and the three variables are plain, no functions there:

- `region`, a string, us-east-1
- `tags`, a list, firstec2 and secondec2
- `ami`, a map of region to AMI ID, three entries

All the functions are in the `aws_instance` block. Five of them:

| Where | Function |
|---|---|
| `ami` | `lookup` |
| `count` | `length` |
| `tags.Name` | `element` |
| `tags.CreationDate` | `formatdate` |
| `tags.CreationDate` | `timestamp` |

A function call is the function name followed by its arguments in brackets, `name(arg1, arg2)`. That is how to spot them when reading a block.

## My analysis

`lookup(var.ami, var.region)`

Takes a map and a key, returns the value at that key. `var.region` is us-east-1, so it pulls ami-08a0d1e16fc3f61ea out of the map. The point of writing it this way is that the same code works in another region without editing the resource block, changing `region` changes which AMI gets picked. AMI IDs are region specific, so a hardcoded one breaks the moment the region changes.

`length(var.tags)`

Returns the number of items in a list. `tags` has two entries, so `count = 2` and two instances get created. The number of instances is driven by the length of the list rather than a hardcoded number, so adding a third name to the list would produce a third instance on its own.

`element(var.tags, count.index)`

Takes a list and a position, returns the item at that position. With `count.index` as the position, copy 0 gets firstec2 and copy 1 gets secondec2. Same job as `var.tags[count.index]` from the count index lab, just written as a function.

`formatdate("DD MMM YYYY hh:mm ZZZ", timestamp())`

`timestamp()` runs first and returns the current time. `formatdate` takes a format spec and the time, and reshapes it into the layout given. The spec here produces something like 27 Aug 2026 14:32 UTC, so the tag ends up with a readable date and time rather than the raw timestamp format.

## What the code creates

Two t2.micro instances in us-east-1, both from ami-08a0d1e16fc3f61ea. The first is tagged Name firstec2, the second Name secondec2, and both carry a CreationDate tag with the time the apply ran, formatted as day, short month, four digit year, hour and minute, and timezone.