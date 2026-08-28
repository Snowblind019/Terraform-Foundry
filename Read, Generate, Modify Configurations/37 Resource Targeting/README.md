# 37 Resource Targeting

Running an operation against one resource instead of everything in the folder.

Files in this folder:

- `resource-target.tf`

---

## Default behaviour

Terraform merges every `.tf` file in the directory and works against the whole thing. That was the load order lab. `resource-target.tf` has three resources in it, an IAM user, a security group and a local file, so a plain `terraform plan` came back with 3 to add.

## The target flag

```sh
terraform plan -target local_file.foo
```

Plan dropped to 1 to add. The other two resources were left alone.

The argument is the resource address, type and local name. Two ways to write it, both do the same thing:

```sh
terraform plan -target local_file.foo
terraform plan -target="local_file.foo"
```

The video mentions one form or the other can fail depending on the operating system, so worth knowing both.

Output includes a warning saying resource targeting is in effect. Terraform tells you the plan is partial rather than letting it look like a normal run.

## Works on the other operations too

Not just plan.

```sh
terraform apply -target local_file.foo
terraform destroy -target local_file.foo
```

Applied with the target and `foo.txt` appeared in the folder, nothing else was created. Destroyed with the same target and the file was gone, again without touching anything else.

## When to use it

Cases from the video:

- Several people are mid-change across ten resources, and one urgent fix is needed on one of them, say adding port 80 to a security group. Targeting applies that one without dragging everyone else's half finished work along.
- Destroying a single resource rather than the whole configuration.
- State has drifted out of sync from a network failure or a provider bug, and one resource needs to be worked on directly.

## When not to

This is not the normal workflow. Every targeted run means the state and the configuration are only partly reconciled, so the recommendation is to use it when there is no other option and otherwise leave it alone. The warning Terraform prints is a hint that it is meant to be the exception.