# 42 Meta-Arguments and Resource Behaviour

Meta-arguments go inside a resource block and change how Terraform treats that resource. This one covers the default behaviour first, then uses `lifecycle` with `ignore_changes` to override it.

Files in this folder:

- `lifecycle-meta-argument.tf`

Docs:

- https://developer.hashicorp.com/terraform/language/resources/behavior
- https://developer.hashicorp.com/terraform/language/meta-arguments/lifecycle

---

## Default resource behaviour

A resource block declares that you want an infrastructure object to exist with those settings. Put it in the file and apply, the object gets created. Take the block out and apply, Terraform assumes you no longer want it and destroys it.

Four things Terraform does on apply:

1. Creates resources that are in the configuration but have no matching object in state.
2. Destroys resources that are in state but no longer in the configuration.
3. Updates in place any resource whose arguments changed and can be changed on the live object. Example given: a security group rule going from port 22 to port 80.
4. Destroys and recreates resources whose arguments changed but cannot be updated in place, because the remote API does not allow it. Example given: swapping an EC2 instance from a Linux AMI to a Windows AMI.

## Seeing points 3 and 4

Started with an instance tagged `Name = HelloWorld` and applied it. Tag showed up on the instance in the console.

Changed the tag value to `HelloEarth` and ran `terraform plan`. That is an in-place update, the instance is not touched, only the tag changes. Applied, and the console showed HelloEarth.

Then changed the AMI ID from the Amazon Linux one to a Windows one and ran plan again. This time the plan showed the instance being destroyed and a new one created, with a forced replacement note in the output. AWS will not let you swap the AMI on a running instance, so Terraform has no in-place path. Reverted the AMI back afterwards.

## Manual changes get reverted

Added a tag by hand in the AWS console, `Env = production`, which is not in the tf file.

`terraform plan` picked it up and showed the tag being removed. Applied, and the tag was gone from the instance. That is point 2 in practice. Terraform treats the configuration as the truth and pulls the live resource back to match it.

That is correct behaviour most of the time. The problem is when you actually want the manual change to stay.

## lifecycle and ignore_changes

The override:

```hcl
lifecycle {
  ignore_changes = [tags]
}
```

Added that inside the resource block, then added `Env = production` back onto the instance by hand and confirmed it was there.

`terraform plan` came back with no changes. Terraform saw the extra tag and left it alone, because `ignore_changes` tells it not to look at that attribute when comparing the live resource against the configuration.

Removed the lifecycle block and ran plan again. It went straight back to wanting to remove the tag.

## The other meta-arguments

`lifecycle` is one of several. The full list mentioned:

- `depends_on`
- `count`
- `for_each`
- `lifecycle`
- `provider`

The `provider` meta-argument is not the same thing as the `provider "aws"` block at the top of the file. Inside a resource it overrides which provider configuration that one resource uses.