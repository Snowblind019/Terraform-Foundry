# 30 Load Order and Semantics

How Terraform decides which files to read when I run a command, and what happens when two files collide.

Files in this folder:

- `file-one.tf`
- `file-two.tf`
- `file-three.tf.json`

---

## What gets loaded

When I run `terraform plan` or `terraform apply`, Terraform loads every file in the directory that ends in `.tf` or `.tf.json`. It does not run them one at a time. It merges them into one configuration and then works against that.

So with three files in the folder, two `.tf` and one `.tf.json`, a single `terraform apply` creates the resources from all three. There is no separate step for the JSON file.

The extension is what matters. A file that does not end in `.tf` or `.tf.json` is ignored.

## Resource addresses have to be unique

Because everything is merged, Terraform expects each file to define a distinct set of objects. Two files cannot declare the same thing.

I started with `file-one.tf`:

```hcl
resource "local_file" "foo" {
  content  = "Hello from KPLABS!"
  filename = "${path.module}/kplabs.txt"
}
```

Then added `file-two.tf` using the same local name `foo`, with different content and a different output filename. Different file, different content, still an error:

```
A local_file resource named foo was already declared in file-one.tf
```

The content being different does not matter. The address `local_file.foo` is what has to be unique, and Terraform cannot tell the two blocks apart.

The error message itself is proof of the merge. Terraform had to have both files open at once to know the name was already taken in the other one.

Renaming the second one to `foo2` fixed it and the plan ran clean.

## Same rule applies to JSON

`file-three.tf.json` is the same idea written in JSON instead of HCL:

```json
{
  "resource": {
    "local_file": {
      "json_example": {
        "filename": "${path.module}/hello_from_json.txt",
        "content": "This file was created using Terraform JSON syntax!"
      }
    }
  }
}
```

Nesting maps onto the HCL block: `resource`, then the type `local_file`, then the local name `json_example`, then the arguments.

With this file in the folder the plan showed 3 to add, including `local_file.json_example`.

Changing `json_example` to `foo2` gave a duplicate resource configuration error, same as before. The uniqueness rule is per configuration, not per file format.

## Subdirectories are not read

Terraform loads the files in the directory it was pointed at, in alphabetical order. It does not walk into subdirectories.

To confirm, I made a `folder-1` subdirectory and moved `file-three.tf.json` into it. The plan then showed only 2 to add. The JSON file was still there, just no longer part of the configuration.

## Splitting files is for me, not for Terraform

Since everything gets merged anyway, naming files `networking.tf` and `compute.tf` makes no difference to Terraform. It is only so a human opening the repo knows where to look.

## Side note on -target

The video mentioned that if I only want to apply one specific resource rather than everything, that is the `-target` flag. Not covered here beyond the mention.