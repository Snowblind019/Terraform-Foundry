# 11 Variable Definition Precedence

The last few videos covered every place a value can come from. This one answers the obvious follow up: if the same variable has a value in more than one of those places, and the values disagree, which one does Terraform actually use.

Docs referred to: [Variable Definition Precedence](https://developer.hashicorp.com/terraform/language/values/variables#variable-definition-precedence)

Files in this folder:

- `variable-precedence.tf`, the EC2 instance with `instance_type` as a variable
- `variables.tf`, declares the variable with a default
- `terraform.tfvars`, sets the same variable to something else

---

## The problem

Nothing stops all four sources being set at the same time. A realistic setup:

| Source | Value |
|---|---|
| `default` in the variable block | `t2.micro` |
| `terraform.tfvars` | `t2.small` |
| `TF_VAR_instance_type` | `t2.large` |

Three different answers for one variable. Terraform does not error on this and it does not warn. It picks one and moves on, so if I do not know the order I am guessing at what is about to get built.

## The order

Terraform loads the sources in this order, and later sources override earlier ones:

1. Environment variables (`TF_VAR_*`)
2. `terraform.tfvars`
3. `terraform.tfvars.json`
4. Any `*.auto.tfvars` or `*.auto.tfvars.json` files
5. Any `-var` or `-var-file` options on the command line

So the command line is the strongest and the environment variable is the weakest of the five.

The `default` in the variable block is not in that list. It sits underneath all of it and is only used when nothing on the list supplies a value. That is the piece the slide skips over, so worth writing down separately.

Two details from the docs that the video does not get into:

- The `*.auto.tfvars` files load in lexical order by file name, so `a.auto.tfvars` loses to `z.auto.tfvars`.
- `-var` and `-var-file` are processed in the order they appear on the command, so if the same variable is passed twice on one line, the last one wins.

Precedence is decided per variable, not per file. A tfvars file can win for one variable and lose for another in the same run.

## Working the examples

Same three examples from the video:

| Env var | terraform.tfvars | `-var` on the command | Result |
|---|---|---|---|
| `t2.micro` | `t2.large` | not used | `t2.large` |
| `t2.micro` | `t2.large` | `m5.large` | `m5.large` |
| `1` | `2` (`.json` says `3`) | `5` | `5` |

The first one catches people out because `t2.large` sitting in a file feels less deliberate than an environment variable that somebody had to go and set. Terraform does not care about intent, only about position in the list.

## What I ran

Started with just the variable and its default:

```hcl
variable "instance_type" {
  default = "t2.micro"
}
```

`terraform plan` showed `t2.micro`, which is expected since nothing else was set.

Then set the environment variable. On Windows that is `sysdm.cpl`, `TF_VAR_instance_type` set to `t2.small`. Closed the terminal and opened a new one, same as in the environment variable video, because the open session still has the old environment. Ran `terraform plan` again and it showed `t2.small`. Environment variable beat the default.

Then added `terraform.tfvars` with `instance_type = "t2.large"`. Ran plan, and it showed `t2.large`. The tfvars file beat the environment variable, which is the ordering above.

Then passed it on the command line:

```bash
terraform plan -var="instance_type=m5.large"
```

Plan showed `m5.large`. Command line beat everything else, nothing else in the folder changed.

Note that the environment variable is set in my shell, not in this folder, so it is not something that can be committed. Anyone rerunning this lab has to set `TF_VAR_instance_type` themselves to see that step.

## Where this actually bites

The reason to know this cold is not the exam, it is the case where a build is running in Jenkins or a pipeline and the value in `terraform.tfvars` is not showing up in the apply. First instinct is to go looking at the tfvars file, and the file is usually fine. Something further up the list is quietly overriding it, normally a `-var` baked into the pipeline command or a `TF_VAR_` set in the runner environment.

So the troubleshooting move is to walk the list from the bottom up: check the command that was actually run, then any auto.tfvars sitting in the directory, then the tfvars files, then the environment. From a security angle this also means the environment of whatever runs Terraform is part of the configuration, even though none of it is in the repo.

If I want to see what a run resolved a variable to without guessing, `terraform plan` output is the check. The plan is the thing that shows the value that is going to be used.

---

## Summary

| Precedence | Source |
|---|---|
| Highest | `-var` and `-var-file` on the command line |
| | `*.auto.tfvars` and `*.auto.tfvars.json` |
| | `terraform.tfvars.json` |
| | `terraform.tfvars` |
| | `TF_VAR_` environment variables |
| Lowest | `default` in the variable block |

Read the list bottom to top and it is just: the closer a value is to the command being run, the more it wins.

---

## Commands run

```bash
terraform plan
terraform plan -var="instance_type=m5.large"
```