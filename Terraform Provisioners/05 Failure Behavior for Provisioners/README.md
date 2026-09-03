# 05 Failure Behavior in Provisioners

By default a failing provisioner fails the whole apply. The `on_failure` setting is how that gets overridden.

Files in this folder:

- `provisioner-behavior.tf`

---

## The default behavior

When a provisioner fails, the `terraform apply` itself fails with it. The resource is then marked as tainted, so on the next apply it is destroyed and created again.

This is the same tainting behavior from the previous lab, just looked at from the angle of what it does to the apply.

## The on_failure setting

For cases where the apply should carry on even though the provisioner failed, and the resource should not be tainted, there is `on_failure`. Production environments often need that flexibility.

Two values:

- `fail` raises the error and stops applying. This is the default, so leaving `on_failure` out gives the same result as setting it to fail. The resource is tainted.
- `continue` makes Terraform ignore the error and carry on with the creation or destruction of resources. The resource is not tainted.

```sh
provisioner "local-exec" {
  command    = "echo1 This is creation time provisioner"
  on_failure = continue
}
```

## Setting up a command that fails

The lab uses `echo1` instead of `echo`. There is no `echo1` binary, so the command fails. Running `echo` on its own from the CLI prints the text as expected, running `echo1` gives a not recognized command error.

## Scenario 1: default

Base code, no `on_failure` set.

```sh
terraform apply -auto-approve
```

The error appears saying echo1 is not a recognized command, the local-exec provisioner fails and the apply fails along with it. Checking the state shows the resource immediately marked as tainted.

Clean up before testing the other scenario:

```sh
terraform destroy -auto-approve
```

Setting `on_failure = fail` explicitly gives exactly this same result.

## Scenario 2: continue

Add `on_failure = continue` and apply again.

```sh
terraform apply -auto-approve
```

The same not recognized command error still appears, since the command genuinely failed. The difference is that Terraform ignores it and the apply completes successfully.

Two ways to confirm nothing was tainted:

- open the tfstate file, the taint entry is not there
- run `terraform plan`, Terraform is not trying to recreate the resource