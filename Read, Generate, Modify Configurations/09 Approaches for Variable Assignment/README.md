# 09 Approaches for Variable Assignment

Every variable needs a value from somewhere. This video covers all the places that value can come from.

Files in this folder:

- `variable-assignment.tf`, an EC2 instance with `instance_type` as a variable
- `variables.tf`, declares the variable with no value attached

---

## What happens with no value at all

Declared the variable and left it empty:

```hcl
variable "instance_type" {}
```

Ran `terraform plan` and it stopped and asked me to type a value in. Entered `t2.micro` and the plan ran with that.

Then ran `terraform apply` and it asked again. The value I typed during the plan is not kept, it only applies to that one command.

So the prompt works, but it is not something to rely on. Anything running unattended would just sit there waiting.

## The four ways to set a value

### 1. default in the variable block

```hcl
variable "instance_type" {
  default = "t2.micro"
}
```

Covered already. Acts as the fallback when nothing else provides a value.

### 2. A .tfvars file

```hcl
instance_type = "t2.micro"
```

Also covered already. `terraform.tfvars` loads automatically, any other name needs `-var-file`.

If a value is in both the default and a tfvars file, the tfvars value wins.

### 3. On the command line with -var

```bash
terraform plan -var="instance_type=m5.large"
```

No prompt, the value comes straight off the command. Confirmed in the plan output, it showed `m5.large`.

### 4. Environment variable

The naming convention is what matters here:

```
TF_VAR_<variable name>
```

So for `instance_type` the environment variable has to be `TF_VAR_instance_type`. Terraform only picks up variables with that prefix.

On Windows, `sysdm.cpl` opens System Properties, then Advanced, then Environment Variables. Set `TF_VAR_instance_type` to `t2.large`.

**The terminal has to be restarted.** Ran `terraform plan` in the terminal that was already open and it still prompted for a value, because that session had the old environment. Closed it, opened a new one, ran plan again, and it picked up `t2.large`.

Linux and Mac work differently and are covered in the next video.

---

## Summary

| Where | How it looks |
|---|---|
| Default | `default = "t2.micro"` in the variable block |
| tfvars file | `instance_type = "t2.micro"` in `terraform.tfvars` |
| Command line | `-var="instance_type=m5.large"` |
| Environment variable | `TF_VAR_instance_type=t2.large` |
| Nothing set | Terraform prompts at the CLI |

More than one of these can be set at once, and when they disagree there is a defined order for which one wins. That ordering is its own video later in the section.

---

## Commands run

```bash
terraform plan
terraform apply
terraform plan -var="instance_type=m5.large"
```