# 32 Terraform Taint

Forcing Terraform to destroy and recreate a resource that has not changed in the configuration.

Files in this folder:

- `taint.tf`

---

## The problem

Someone logs into a server Terraform built and changes things by hand. Terraform does not know about any of it, so the state and the real resource drift apart. Two things go wrong from there.

First, rebuilding the same setup in another account or environment does not produce the same thing, because the working version only got to be the working version through manual edits that are not in the code.

Second, and this is the case the video focuses on, the manual changes break the box. The application stops working and I want back to the version Terraform originally built.

Two ways out. Import the manual changes so the code reflects reality, or throw the resource away and let Terraform build it again from the configuration. This lab is the second one.

## Why apply does nothing

After the instance is up, running `terraform apply` again reports no changes and says the infrastructure matches the configuration. From Terraform's point of view that is true. The arguments in the file still match what state says was created. Whatever happened inside the operating system is invisible to it, so there is nothing to plan.

## -replace

```sh
terraform apply -replace="aws_instance.myec2"
```

The argument is the resource address, type and local name. This tells Terraform to replace the object even though nothing in the configuration calls for it.

The plan came back as 1 to add, 1 to destroy, with the instance marked for replacement. Confirmed with yes. It destroyed the old instance first, then created the new one. In the EC2 console, with terminated instances shown, the old one is terminated and a new one is running.

The new instance comes from the AMI in the configuration, so it starts out however that image was built, without the manual changes.

## Naming

This used to be `terraform taint`, which marked a resource as tainted in state so the next apply would replace it. From 0.15.2 onward HashiCorp recommends `-replace` on apply instead.

Worth knowing both, since the exam and plenty of people still say taint when what they mean is recreating a resource Terraform already manages.

## Note on the provider block

The course file has the access key and secret key written into the provider block. Mine does not, I am using the CLI credentials, same as the earlier labs.