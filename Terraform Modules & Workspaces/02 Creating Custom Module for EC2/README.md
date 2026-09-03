# 02 Creating the EC2 Module

Building the first module of my own, rather than pulling one from the registry. The module is for an EC2 instance.

Files in this folder:

- `main.tf`

---

## Where the file goes

The previous video set up the base structure, `kplabs-terraform-modules` with two subfolders inside it, `modules` and `teams`. This video works in the `modules` side.

```
kplabs-terraform-modules/
  modules/
    ec2/
      main.tf
  teams/
```

Inside `modules/ec2`, create a new file called `main.tf` and paste the EC2 code into it. That is the entire module.

## The code

```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "myec2" {
  ami           = "ami-0bb84b8ffd87024d8"
  instance_type = "t2.micro"
}
```

The name "module" suggests something complex has to be written. It does not. This is the ordinary code for creating an EC2 instance, the same code as anywhere else, and it is hardcoded to us-east-1 with a hardcoded AMI. Nothing extra is present.

## Can a module be this small

Yes. How much code goes into a module depends on the requirement. It can be three or four lines, it can be a hundred lines.

The thing that actually matters is that whatever sits in the modules folder can be referenced by the various teams. Team A should be able to use the EC2 code without writing an `aws_instance` resource themselves.

## Why public modules are so much bigger

A professionally written public EC2 module has multiple files, examples, a license, and so on. Its `main.tf` runs to around 605 lines against the four lines here.

The reason is the number of arguments a public module has to expose. Looking through one, it covers tags, subnet, source destination check, `user_data_base64`, `maintenance_options`, and many more. Every option available for creating an EC2 instance is in there.

That is deliberate. A public module gets referenced by hundreds of organizations with a wide variety of use cases, and none of them should be restricted by an option the module left out.

A module written for one organization does not have that problem. It only needs the options that organization actually uses. If tags are needed, add them. If they are not, leave them out and keep the code base smaller. This is why in-house modules are usually much smaller than the public ones.

## What comes next

The next video calls this module from the `teams` folder, which is where the referencing gets covered.

## Commands used

None. This video only creates the file, nothing is run against it yet.