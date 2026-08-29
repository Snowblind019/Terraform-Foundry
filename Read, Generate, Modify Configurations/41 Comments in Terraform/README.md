# 41 Comments in Terraform

The three comment syntaxes Terraform supports, and using a block comment to keep a resource in the file without running it.

Files in this folder:

- `tf-comments.tf`

Docs:

- https://developer.hashicorp.com/terraform/language/syntax/configuration#comments

---

## Why comment

A comment is a text note in the source that explains what the code does. Reading a file that opens with a few lines saying what the program is for tells you the point of it before you read a single line of the actual code.

## The three syntaxes

```hcl
# single line comment
// single line comment, alternative to #

/*
multi line
comment
*/
```

`#` and `//` do the same thing, both run to the end of the line. `#` is the recommended one for single lines.

`/* */` is for comments spanning multiple lines. Everything between the opening and closing marker is a comment.

## The multi line marker has to be closed

`/*` starts the comment, `*/` ends it. If you open one and never close it, everything below it in the file is commented out, not just the lines you meant. That is the thing to watch with this one.

You can also just put a `#` on each of the three lines instead. Both get you a three line comment, the block form is only shorter.

## Commenting out a resource

The practical use in the video. Say you have two resources in a file and you want the second one to stay in the file but not run for now. Wrap it in `/* */`:

```hcl
/*
resource "null_resource" "demo_run2" {
  ...
}
*/
```

`terraform plan` then only picks up the first resource. The second one is still sitting there in the file, Terraform just does not see it. When you want it back, delete the two markers and it runs like normal.

That is the same idea as deleting the block and pasting it back later, except you do not have to keep the code somewhere else in the meantime.