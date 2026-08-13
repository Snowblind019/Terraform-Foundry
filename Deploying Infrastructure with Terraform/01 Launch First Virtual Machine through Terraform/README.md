# 01 - First EC2 Instance

Goal here is simple: get one virtual machine running in AWS from code instead of from the console.

## The naming thing

"Virtual machine" is a generic term and every provider has their own word for it. AWS calls it an EC2 instance (Elastic Compute Cloud). DigitalOcean calls it a droplet. Same idea, different label, and the resource type you write in Terraform follows whatever that provider decided to call it. So in AWS land, a VM is `aws_instance`.

## The two decisions you always make

Before you write a line of Terraform, you're making the same two choices you'd make clicking through the console.

**Region.** AWS runs in a lot of regions and each one has a code. Singapore is `ap-southeast-1`, North Virginia is `us-east-1`, Oregon is `us-west-2`. The region decides where the box physically lives, and it has to be set somewhere before Terraform will do anything.

**The machine spec.** That breaks down into two fields:

- `ami` is the Amazon Machine Image, which is basically the OS. Amazon Linux, Ubuntu, Windows, whatever.
- `instance_type` is the CPU and memory combo. `t3.micro` is small and cheap. `c3.8xlarge` is 32 vCPU and 60 GiB and will happily eat your card.

The AMI ID is the part that catches people. **AMI IDs are region specific.** The exact same Amazon Linux image has a different ID in `us-east-1` than it does in `us-west-2`. If you copy an AMI ID out of someone's code and your region is different, the apply fails or you get something you didn't expect. Always pull the AMI ID from the console in the region you're actually deploying into.

## The provider block

```hcl
provider "aws" {}
```

This has to be present at least once before `terraform init` will do anything useful. It tells Terraform "download the AWS plugin, I'm going to be talking to AWS."

Mine is empty because I let region and credentials come from the environment (`AWS_REGION`, `AWS_PROFILE`). The course version fills it in like this:

```hcl
provider "aws" {
  region     = "us-west-2"
  access_key = "AKIA..."
  secret_key = "..."
}
```

That works fine and there's nothing wrong with it for a throwaway lab. I'm just not doing it in a repo I push, because hardcoded keys in git are how people end up with a crypto miner running in their account. Region on its own is safe to hardcode if you want to pin it.

## The resource block

```hcl
resource "aws_instance" "WinterdayEC2" {
  ami           = "ami-091124c3965bce679"
  instance_type = "t3.micro"

  tags = {
    Name = "WinterdayEC2"
  }
}
```

Three parts to that first line:

1. `resource` is the keyword. It means "I want this thing to exist."
2. `aws_instance` is the **resource type**. This is fixed. It comes from the provider docs and you can't invent it or change the spelling. Want a key pair instead? That's `aws_key_pair`. A load balancer? `aws_alb`. Look it up, use it exactly.
3. `WinterdayEC2` is the **local name**. This one is mine to pick. It's a label Terraform uses internally to keep track of this specific resource, and it never shows up in AWS anywhere.

That last point is worth being clear on, because I had it wrong at first: the local name has nothing to do with the instance name in the AWS console. If you launch this and look at your EC2 list, the Name column is blank. The console Name is just a tag with the key `Name`, which is why the `tags` block above exists. Local name is for Terraform, the Name tag is for the console.

## Running it

```bash
terraform init
terraform plan
terraform apply
```

`init` downloads the AWS plugin. It takes a minute or two the first time because the plugin is a few hundred MB.

`plan` reads your code, compares it against what already exists, and prints what it intends to do. Creating nothing, changing nothing until you say so.

`apply` runs that same plan again, shows you the summary, and waits for you to type `yes`. Mine took about 37 seconds to come back with the instance running.

## Changing something

This is where it clicks. Add a tag, save, run `plan` again, and instead of "1 to add" you get "1 to change." Terraform already knows the instance exists, so it works out the difference and only does that. Remove the tag and re-apply and the tag goes away. You're not describing steps, you're describing the end state you want and letting it work out how to get there.

## Files

- `main.tf` - the config for this section.
