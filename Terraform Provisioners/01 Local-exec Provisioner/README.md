# 01 Local-Exec Provisioner

First practical of the provisioner section. After the EC2 instance is created, a local-exec provisioner writes the instance IP into a file on the machine running Terraform.

Files in this folder:

- `local-exec.tf`

Docs:

- https://developer.hashicorp.com/terraform/language/resources/provisioners/local-exec
- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance

---

## Provisioners go inside the resource

The provisioner block has to be written inside the resource block it belongs to. Putting it outside the resource does not work.

```sh
resource "aws_instance" "myec2" {
   ami = "ami-04e5276ebb8451442"
   instance_type = "t2.micro"

   provisioner "local-exec" {
     ...
   }
}
```

The format is the keyword `provisioner` followed by the provisioner type in quotes. For this lab that is `local-exec`.

## The command argument

Inside the local-exec block you specify `command`, which is whatever you want run on the local system after the resource is created.

```sh
provisioner "local-exec" {
  command = "echo ${self.private_ip} >> server_ip.txt"
}
```

The echo output is redirected into `server_ip.txt`. That file does not exist before the apply, it gets created when the provisioner runs.

## What self means

`self` refers to the resource the provisioner is attached to. Here the provisioner sits inside `aws_instance.myec2`, so `self.private_ip` is the private IP of that instance.

## private_ip and public_ip

Both are attributes on the `aws_instance` resource, listed under the attribute reference in the provider docs.

- `private_ip` is the private IP assigned to the instance
- `public_ip` is the public IP assigned to the instance

Either one works in the command, it just changes which address ends up in the file. The final code in this folder uses `private_ip`.

## Running it

The AMI in this code is for us-east-1. If you are applying in a different region the AMI ID has to be replaced with one valid for that region.

```sh
terraform apply -auto-approve
```

Terraform creates the EC2 instance first. Once creation is complete it moves on to provisioning, and the CLI output shows the local-exec provisioner running.

After the apply, `server_ip.txt` exists in the working directory and contains the private IP of the instance. Checking the instance in the AWS console shows the same address.

## Cleaning up

```sh
terraform destroy -auto-approve
```

The instance goes from running to shutting down and then to terminated. Doing this avoids leaving the instance up and accruing charges.

## Other uses

Echo into a file is a simple example. Anything you want executed locally after the resource is created can go in `command`, for example running a local script, or kicking off an Ansible run against the server that was just built.