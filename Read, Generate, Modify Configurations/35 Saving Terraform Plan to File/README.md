# 35 Saving Terraform Plan To File

Writing a plan out to disk and applying that instead of re-planning.

Files in this folder:

- `local_file.tf`

---

## The workflow

```sh
terraform plan -out=infra.plan
terraform apply infra.plan
```

`-out` writes the plan to whatever filename I give it, the extension does not matter. Apply then takes that file as its argument and builds from it, rather than working out a fresh plan.

Note that apply skips the confirmation prompt when given a saved plan. There is nothing to confirm, the decision was made when the plan was saved.

## What the saved plan actually holds

Ran through the normal loop first, init, plan, apply, and confirmed `terraform.txt` was created with `Hello World` in it. Destroyed, then saved a plan with `-out=infra.plan`.

Then edited the resource before applying, changing the filename to `terraform2.txt` and the content to `NEW CONTENT`, saved the file, and ran `terraform apply infra.plan`.

The result was `terraform.txt` containing `Hello World`. The edits were ignored completely.

That is the whole point. The saved plan is a fixed set of actions from the moment it was created. Apply does not re-read the configuration, so changes made after the plan was saved have no effect on that apply.

## Why bother

In an environment where several people touch the same code, a plan reviewed on Monday and applied on Wednesday can produce something different if someone pushed in between. Applying a saved plan removes that gap, what got reviewed is what gets built.

Same reason it fits change management. If the plan output is the documented proof attached to a change record, then applying that exact file is what makes the approved change and the executed change the same thing.

## Reading the file

The plan file is binary. Opening it in an editor gives an unsupported encoding message.

```sh
terraform show infra.plan
```

Prints it back in the same readable form as the original plan output. Confirmed the content was still the old `terraform.txt` and `Hello World`, so the edits really were not in there.

```sh
terraform show -json infra.plan
```

Same thing as JSON, for anything that needs to parse it programmatically. It comes out unformatted on one line, so pipe it through jq:

```sh
terraform show -json infra.plan | jq
```

The video also demonstrates pasting the JSON into online formatters, then says not to do that with real work, since plan output can contain sensitive values. jq keeps it local. On Fedora it is `sudo dnf install jq`.