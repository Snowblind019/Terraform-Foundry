# 25 Data Sources - Fetching Latest AMI ID

Theory for one of the main real world uses of data sources. The implementation is video 26.

Files in this folder:

- `data-source-ami.tf`, the hardcoded version that demonstrates the problem

---

## The requirement

Write Terraform that creates a server using the latest operating system image. Amazon Linux in this case, but the same applies to Ubuntu, Windows Server or anything else.

## The manual approach

Go to the EC2 console, start the launch instance flow, pick the operating system, copy the AMI ID it shows, and paste that ID into the code:

```hcl
resource "aws_instance" "web" {
  ami           = "ami-0abcd1234efgh5678"
  instance_type = "t2.micro"
}
```

It works, and it is what most people do first. The problem is that it is a hardcoded static value, and hardcoding static values in production code means coming back to edit the code every time something changes.

## Why the AMI ID in particular is a bad thing to hardcode

AMI IDs are region specific. The same operating system, the same latest image, has a different ID in every region.

Checking this in the console, Ubuntu in Mumbai showed an ID starting 18c7, and switching the console to Singapore showed one starting b7b for the same OS. Nothing is shared between them.

So an AMI ID copied out of one region only works in that region. Moving the code to another region means finding the new ID and editing the code, which is exactly the repeated manual work worth avoiding.

## The failure, in practice

The AMI ID was copied from North Virginia, and the provider was then pointed at ap-south-1, which is Mumbai.

`terraform plan` did not complain. It showed one instance to create with that AMI ID, and looked completely normal.

`terraform apply -auto-approve` failed immediately, with an error saying the AMI ID was invalid and could not be found.

That gap is the part to remember. Plan does not validate the AMI against the region, so this class of mistake is not caught until the apply is already running.

## What the code should do instead

Rather than being told which image to use, the code should ask AWS for the latest image itself, in whichever region it is running in. The flow:

1. The provider sets the region
2. A data source block queries AWS for the latest AMI matching the operating system wanted
3. The AMI ID it returns gets passed to the `aws_instance` resource block, which creates the server

Nothing about the image is written into the code, so the same configuration works across regions without edits, and picks up new image releases on its own.

Building that is the next video.