# 26 Data Sources - Fetching the Latest AMI ID

The problem with hardcoding an AMI ID, and the data source that replaces it. Video 25 is the theory, video 26 is the build.

Files in this folder:

- `demo-ec2.tf`, the finished version, AMI fetched by data source

Docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami

---

## The requirement

Terraform code that creates a server using the latest operating system image. Amazon Linux in the example, but the same applies to Ubuntu, Windows Server or anything else.

## The manual approach and why it breaks

Go to the EC2 console, start the launch instance flow, pick the OS, copy the AMI ID, paste it into the code:

```hcl
resource "aws_instance" "web" {
  ami           = "ami-0abcd1234efgh5678"
  instance_type = "t2.micro"
}
```

Works, and it is what most people do first. But AMI IDs are region specific. The same OS, the same latest image, has a different ID in every region. Checking in the console, Ubuntu in Mumbai showed an ID starting 18c7, and the same image in Singapore showed one starting b7b. Nothing carries over.

So an ID copied from one region only works in that region, and moving the code means finding the new ID and editing it in. That is the repeated manual work worth designing out.

### The failure in practice

AMI ID copied from North Virginia, provider then pointed at ap-south-1.

`terraform plan` did not complain. It showed one instance to create with that AMI ID and looked completely normal.

`terraform apply -auto-approve` failed immediately with an error saying the AMI ID was invalid and not found.

That gap is the part worth remembering. Plan does not check the AMI against the region, so this is not caught until the apply is already running.

## Finding the right data source

In the AWS provider docs, under EC2, `aws_ami` appears in both sections. The resource creates an AMI, which is not what is wanted here. The data source gets the ID of a registered AMI for use in other resources, which is.

The same list can be browsed in the console under AMIs, switching from Owned by me to Public images and filtering on owner alias amazon. Useful for working out what to filter on, because it shows the AMI names and their structure.

## Building the block

```hcl
data "aws_ami" "myimage" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}
```

`most_recent = true`, if the filter matches more than one image, use the newest.

`owners = ["amazon"]`, the same filter applied in the console.

The filter on name is what picks the specific OS, since Amazon publishes Windows Server, Amazon Linux, Ubuntu and plenty more. AMI names have a set structure, for example `al2023-ami-2023-...` for Amazon Linux 2023, or `ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-...` for Ubuntu 22.04 LTS. The tail of the name is a date, and it changes whenever Amazon republishes the image with new patches, which also changes the AMI ID. So the date gets replaced with a `*` wildcard, and the filter keeps matching after every republish.

## Referencing it

The data source has to be wired into the resource, otherwise the plan still shows the old hardcoded value. Finding the right attribute means going to the Attributes section of the data source docs. The one holding the AMI ID is `image_id`:

```hcl
resource "aws_instance" "web" {
  ami           = data.aws_ami.myimage.image_id
  instance_type = "t2.micro"
}
```

`terraform plan` after that showed a populated AMI ID rather than the hardcoded one. Cross checking it in the console under public images, it was the same Ubuntu image, but dated 1 April 2024 rather than the 1 March 2024 one seen earlier. It picked up the newer republish on its own, which is the whole point.

Changing the region to ap-south-1 and planning again populated a different AMI ID, correct for that region, with no edits to the filter.

## The architecture error

The first `terraform apply` failed with InvalidParameterValue, saying the architecture of the instance type does not match the arm64 architecture of the AMI.

Cause was in the filter. The name being matched contained `arm64-server`, so the data source returned the ARM build of the image, and t2.micro is x86_64. Not every instance type supports every architecture.

Looking up an x86_64 Ubuntu image in the console, the architecture field reads x86_64 and the name reads `ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-...`. Changing the filter value to the amd64 name fixed it, and the apply completed with one instance running in Mumbai.

Worth carrying forward: the filter does not only select the OS, it selects the architecture too, and getting that wrong passes plan and fails at apply.