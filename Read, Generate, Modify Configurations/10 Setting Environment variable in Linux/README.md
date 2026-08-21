# 10 Setting Environment Variable in Linux

The Linux and Mac version of the environment variable approach from the last video. Same idea, different commands.

Docs referred to: [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

---

## Listing what is set

```bash
printenv
```

Shows every environment variable in the current shell. Windows uses something different.

## Setting one

```bash
export TF_VAR_instance_type=m5.large
```

Check it took:

```bash
echo $TF_VAR_instance_type
```

## The prefix is the whole point

The video sets it wrong first on purpose:

```bash
export instance_type=t2.large
```

`echo` shows the value, so the variable exists as far as the shell is concerned. But `terraform plan` still prompted for `instance_type`.

Terraform only looks at environment variables starting with `TF_VAR_`. Anything else is invisible to it, no matter what it is named. Set it again as `TF_VAR_instance_type` and the prompt goes away.

That is the takeaway. The variable existing is not enough, the prefix is what makes Terraform pick it up.

## export only lasts for that shell

Nothing in the video about this, but `export` sets the variable for the current session only. Open a new terminal and it is gone. For it to stick it has to go in a shell profile.

Same effect as the Windows lesson from the last video, just from the other direction: there, the already-open terminal could not see a newly created variable. Environment variables belong to the shell session.

## The error after the prompt went away

Once the variable was picked up, plan ran and then failed on credentials, because the provider block had no keys in it yet. Different problem, unrelated to variables. The point was that the prompt stopped appearing, which is what the video was demonstrating.

## Notes on the demo file

Two things in the file that are demo shortcuts rather than good practice:

The access key and secret key are written directly into the provider block. Fine for a throwaway demo on a temporary instance, not something to do in a real file, and definitely not something to commit.

The `variable` block is in the same file as the resource. Terraform loads all `.tf` files in the folder so it works, but the convention from the earlier video is to keep it in `variables.tf`.

Also worth checking before running: the provider is set to us-west-2 while the AMI is an ap-south-1 image. They have to match or the apply fails.

---

## Commands run

```bash
printenv
export TF_VAR_instance_type=m5.large
echo $TF_VAR_instance_type
terraform init
terraform plan
```