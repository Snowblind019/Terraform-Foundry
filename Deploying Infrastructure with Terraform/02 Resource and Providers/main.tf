provider "aws" {}

# Declaring a second provider is enough on its own to make terraform init pull
# its plugin down. I'm not creating anything in Azure here, this is just to see
# both plugins land in .terraform/providers side by side. Creating actual Azure
# resources would need credentials in this block.
provider "azurerm" {
  features {}
}

# First instance.
resource "aws_instance" "WinterdayEC2" {
  ami           = "ami-091124c3965bce679"
  instance_type = "t3.micro"

  tags = {
    Name = "WinterdayEC2"
  }
}

# Second instance. Same resource type, different local name. The type plus the
# local name has to be a unique pair inside the configuration, so this would
# error out at plan time if I called it WinterdayEC2 as well.
resource "aws_instance" "SnowydayEC2" {
  ami           = "ami-091124c3965bce679"
  instance_type = "t3.micro"

  tags = {
    Name = "SnowydayEC2"
  }
}

# Worth remembering: aws_instance can only ever be handled by the AWS plugin.
# Declaring azurerm above doesn't let me write Azure resources into an AWS block
# or the other way round. Each resource type belongs to exactly one provider.
