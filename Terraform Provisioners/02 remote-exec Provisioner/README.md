# 02 Remote-Exec Provisioner

Practical for remote-exec. After the EC2 instance is created, Terraform connects to it over SSH and installs nginx on it.

Files in this folder:

- `remote-exec.tf`

Docs:

- https://www.terraform.io/language/resources/provisioners/remote-exec
- https://www.terraform.io/language/resources/provisioners/connection
- https://www.terraform.io/language/functions/file
- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance

---

## Two blocks are needed

Like local-exec, the provisioner stays inside the resource. Unlike local-exec, remote-exec needs a second block alongside it.

- the `connection` block, which tells Terraform how to log into the server
- the `provisioner "remote-exec"` block, which holds the commands to run on that server

The docs state that remote-exec requires a connection and supports both ssh and winrm. WinRM is Windows Remote Management, so it is the option for a Windows server. For Linux the protocol is ssh.

## Filling in the connection block

```sh
connection {
  type        = "ssh"
  user        = "ec2-user"
  private_key = file("./terraform-key.pem")
  host        = self.public_ip
}
```

`user` depends on the operating system image. On AWS with an Amazon Linux image the default user is `ec2-user`. A different provider has a different default, on Digital Ocean it can be root.

`password` is the default authentication option shown in the connection docs, but AWS images have password authentication disabled by default, so it cannot be used here. The private key option is what replaces it.

`host` is `self.public_ip`. `self` is the resource the provisioner sits in, so this resolves to the public IP of the instance being created.

For winrm the default user in the docs is Administrator.

## The commands

```sh
provisioner "remote-exec" {
  inline = [
    "sudo yum -y install nginx",
    "sudo systemctl start nginx",
  ]
}
```

The first command installs nginx, the second starts it. These run on the server, not locally.

## The instance needs the key attached

The connection block only says which key to authenticate with. The instance also has to be created with that key pair, otherwise there is nothing to log in against.

Create the key pair in the AWS console first. Name it `terraform-key` and choose the pem format. It downloads automatically, and the file goes into the same folder as the Terraform code.

Then attach it to the instance with the `key_name` argument from the aws_instance argument reference:

```sh
key_name = "terraform-key"
```

The value here is the key pair name in AWS. The `.pem` extension belongs on the filename in the connection block, not on `key_name`.

## Port 22 has to be open

Terraform connects over SSH, so the instance needs inbound port 22 allowed. For this lab the security group was created manually in the console, named `provisioner-sg`, with inbound rules allowing SSH and also HTTP since nginx is being installed.

It is attached with `vpc_security_group_ids`, which takes the security group ID:

```sh
vpc_security_group_ids = ["sg-0edf854d7112cfbf4"]
```

## Key file permissions on Mac and Linux

If the permissions on the pem file are too open, SSH refuses to use it. From the folder holding the key:

```sh
chmod 400 terraform-key.pem
```

This does not apply on Windows.

## First error: no key found

The first apply created the instance, then failed during provisioning:

```
Failed to read ssh private key: no key found
```

The cause was passing the filename directly. Reading the description of `private_key` in the connection docs, the argument takes the contents of the key, not a path, and the contents can be loaded from a file on disk using the `file` function.

```sh
private_key = file("./terraform-key.pem")
```

Since the instance had already been created at that point, the fix was to destroy first and then apply again:

```sh
terraform destroy -auto-approve
```

## Second thing to fix: sudo

The commands run as `ec2-user`, which does not have administrative privilege. Installing packages with yum, and starting nginx which binds to port 80, both need it. Running an install without sudo gives an error saying the command has to be run with superuser privilege, so `sudo` goes in front of both inline commands.

## Running it

```sh
terraform validate
terraform apply -auto-approve
```

The instance goes to pending, then running. Terraform then connects over SSH, the output shows Connected, and the inline commands run. The nginx installation and its dependencies scroll through the output.

Once it finishes, opening the instance public IP over HTTP in a browser shows the default Welcome to nginx page.

## Troubleshooting a failed connection

Sometimes the instance is created but Terraform cannot connect to it. When that happens, try connecting manually from the CLI using the same values that are in the connection block, the same key, the same user and the public IP. If the manual SSH fails it gives an error that points at the actual cause.