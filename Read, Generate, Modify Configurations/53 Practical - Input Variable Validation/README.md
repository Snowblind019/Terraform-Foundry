# 53 Input Variable Validation, Practical

Writing the validation block from the previous video. A `db_password` variable that only accepts a value of at least 12 characters.

Files in this folder:

- `input-validation.tf`

Docs:

- https://developer.hashicorp.com/terraform/language/values/variables

---

## The code

```hcl
variable "db_password" {
  type = string

  validation {
    condition     = length(var.db_password) >= 12
    error_message = "Length of Database Password must be equal to or greater than 12 characters"
  }
}
```

## The three parts

**validation block.** The block that holds everything else. It goes inside the variable block.

**condition.** A boolean expression that has to evaluate to true for validation to pass. Here it asks whether the length of `var.db_password` is 12 or more. True and the plan continues, false and it fails.

**error_message.** What the user sees in the CLI when the condition fails. Write something that actually explains the problem.

## The length function

`length` is what does the work in the condition. Running it on its own, `length("hello")` returns 5.

In the condition it is applied to the variable rather than a literal. Whatever value gets assigned to `db_password` is what gets measured, and that number is compared against 12.

Other functions can be used in a condition. `length` is just the one that fits this case.

## Running it

First `terraform plan` failed, not on the validation but on the type. Writing `type = "string"` with quotes produces an error saying Terraform 0.11 and earlier required constraints in quotes, that this form is deprecated, and that it will be removed in future. Removing the quotes so it reads `type = string` fixes it.

Second plan: no value is set in `terraform.tfvars`, so Terraform prompts for one. Entering `admin1234` comes back with the error message from the validation block, since that is 9 characters. Entering something 12 characters or longer plans cleanly.

## Commands used

```sh
terraform plan
```