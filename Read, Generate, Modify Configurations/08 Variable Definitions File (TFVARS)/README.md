# 08 Variable Definitions File (TFVARS)

Splitting variables into two files, one that declares them and one that holds their values.

Docs referred to: [Input Variables](https://developer.hashicorp.com/terraform/language/values/variables)

Files in this folder:

- `variable-definition-file.tf`, the EC2 instance
- `variables.tf`, declares the variable
- `terraform.tfvars`, the value

---

## The split

In the last section the value sat in the variable block as a `default`. That works, but the recommended structure separates the two:

| File | What is in it |
|---|---|
| main config | the resources |
| `variables.tf` | the variable declarations, no values |
| `terraform.tfvars` | the values, no variable blocks |

So `variables.tf` becomes:

```hcl
variable "ami" {}
```

and `terraform.tfvars` becomes:

```hcl
ami = "ami-0e670eb768a5fc3d4"
```

Note the syntax difference. The `.tfvars` file is plain key value assignments, there is no `variable` keyword in it.

## Why bother

The point comes out when there is more than one environment.

`variables.tf` stays the same no matter what. Then there is a `dev.tfvars` and a `prod.tfvars`, each with different values for the same variables. Different VPN IP, smaller instance type in dev, larger in prod.

Which one gets used is decided at run time:

```bash
terraform plan -var-file="prod.tfvars"
terraform plan -var-file="dev.tfvars"
```

Same configuration, same variable declarations, different values. Nothing in the code has to be edited to switch environments.

## terraform.tfvars is loaded automatically

If the file is named `terraform.tfvars`, Terraform finds it on its own and no flag is needed.

Renamed it to `prod.tfvars` and ran `terraform plan`, and instead of running it stopped and prompted me to type in a value for `ami`. Terraform could not find the value anywhere, so it asked.

Adding `-var-file="prod.tfvars"` made it work. So the rule is: `terraform.tfvars` is automatic, anything else has to be passed explicitly.

## default vs tfvars

Tested all three combinations:

- Value only in `terraform.tfvars`, no default: uses the tfvars value
- Default only, empty tfvars: uses the default
- Both set: **uses the tfvars value and ignores the default**

So `default` is a fallback. It only applies when Terraform cannot find the value anywhere else. Anything set explicitly wins.

This is the first piece of variable precedence. There are more ways to set a variable than these two, and the ordering between all of them comes up in a later video.

## AMI IDs are per region

The AMI in this lab is an ap-south-1 image, which is why the provider block points there. The same image in us-east-1 has a completely different ID. Running this in the wrong region fails.

Good candidate for a variable for that reason, and worth putting a description on it so nobody has to guess which region it belongs to.

---

## Commands run

```bash
terraform plan
terraform apply
terraform plan -var-file="prod.tfvars"
```