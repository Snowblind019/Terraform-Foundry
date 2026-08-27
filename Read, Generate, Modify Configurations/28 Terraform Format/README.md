# 28 Terraform fmt

`terraform fmt` rewrites configuration files into the canonical Terraform format and style. It matters most on shared codebases, where everyone writes slightly differently and the inconsistency makes reviews and debugging harder than they need to be.

Files in this folder:

- `demo.tf`, a badly indented file to run fmt against

---

## What it fixes

Bad indentation is not an error. A misaligned resource block plans and applies exactly the same as a tidy one. What it costs is readability, and on a codebase several people touch, that adds up.

```hcl
resource "local_file" "this" {
content = "kplabs"
    filename = "${path.module}/kplabs.txt"
}
```

Running `terraform fmt` rewrites it in place, aligned and consistent. No prompt, no confirmation, it just makes the change and prints the names of the files it touched.

On a five line file the obvious objection is that fixing the indentation by hand is quicker. That holds until the file is 600 lines across several modules, which is the normal case in an enterprise codebase. Hand formatting does not scale, the command does.

## -diff

Plain `fmt` tells you which files it changed, not what it changed inside them.

```sh
terraform fmt -diff
```

Prints the changes in diff form, removed lines marked with a minus and added lines with a plus, so the exact style adjustments are visible. Useful before running it against production code.

The file still gets rewritten. `-diff` adds the output, it does not make the command read only. That is what `-check` is for.

One catch: this needs a `diff` binary on the system. On Windows it is not there by default and the command fails saying the diff executable was not found. Linux and macOS have it, `which diff` confirms.

## -recursive

By default `fmt` only looks at files in the current directory. Files in subdirectories are left alone, which is easy to miss on a project with modules in nested folders.

```sh
terraform fmt -recursive
```

Demonstrated by creating `folder-1/file.tf` with the same bad indentation as `demo.tf`. Plain `fmt` reported only `demo.tf` and left the subfolder file untouched. With `-recursive` both were fixed.

## -check

For CI/CD, where the pipeline should verify formatting without modifying anything.

```sh
terraform fmt -check
```

Reports which files would be changed, changes nothing, and sets the exit status:

| Exit status | Meaning |
|---|---|
| 0 | Nothing needs formatting |
| 3 | One or more files need formatting |

The pipeline branches on that. Zero means carry on, three means the code is not formatted and something should happen before it reaches production.

Tested by breaking the indentation in `demo.tf` and running the check, which listed the file and returned 3. After fixing the file, the same command listed nothing and returned 0.

## The important limit

`terraform fmt` never changes the behaviour of the infrastructure. It only changes how the code looks.