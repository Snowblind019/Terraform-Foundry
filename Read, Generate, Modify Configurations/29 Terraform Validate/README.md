# 29 Terraform Validate

`terraform validate` checks whether a configuration is syntactically correct. It catches things like unsupported arguments and references to variables that were never declared.

Files in this folder:

- `terraform-validate.tf`, a valid file, with the two ways to break it noted in comments

---

## On a valid file

```sh
terraform validate
```

Reports success and says the configuration is valid. Nothing else to it.

## Unsupported argument

Adding an argument the resource type does not accept, `sky = "blue"` inside an `aws_instance` block, and validating again produces an error saying there is an unsupported argument, and names which one.

Useful because the name is usually enough to spot the typo or the argument that belongs to a different resource type.

## Undeclared variable

Replacing the `instance_type` value with `var.instancetype`, without a matching `variable` block anywhere, gives a different error: reference to undeclared input variable, again naming the variable.

Easy mistake to make when moving a hardcoded value out into a variable and forgetting the second half of the job.

## Relationship to plan

`terraform plan` runs the same validation behind the scenes, so the same errors appear there too. `validate` just does that part on its own, without needing to reach the provider or produce a plan.