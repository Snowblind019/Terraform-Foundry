#before doing terraform init, the provider has to be specified at least once
provider "aws" {}

#resouce initiates a group with specific choices/actions, "aws_instance" is one of them and has to be written exactly whilst the "WinterdayEC2" is the name and can be whatever but it has to be unique on the account
resource "aws_instance" "WinterdayEC2" {
    ami = "ami-091124c3965bce679"
    instance_type = "t3.micro"

    tags = {
        Name = "WinterdayEC2"
    }
}

#this is how you add multiple resources, you have to list each individually, but the name after the "aws_instance" has to be unique from the other ones
resource "aws_instance" "SnowydayEC2" {
    ami = "ami-091124c3965bce679"
    instance_type = "t3.micro"

    tags = {
        Name = "SnowydayEC2"
    }
}

#you're only able to use commands related to the specific provider; if provider is azurerm, aws commands like aws_instance wouldn't work. Also the core of Terraform is the same regardless of provider, for the provider specific commands the docs are there for easy reference.

#by default when specifying a provider, it searches the hashicorp provider registry. So when specifying a provider like digitalocean who isn't a hashicorp maintained provider it won't find it. All non-hasshicorp maintained providers have to be specified like provider "greg-oc/87347" {} or provider "digitalocean/digitalocean" {}.

#if you're getting issues running the 'terraform init' command when specifying one of these providers, you can search them up and get the specified template from Hashicopr themselves. This also works for hashicorp maintained ones like aws, but for ease of access those can be simplified to just provider "aws" {}.
terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}