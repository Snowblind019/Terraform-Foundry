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

#this is how you add multiple resources, you have to list each individually 
resource "aws_instance" "SnowydayEC2" {
    ami = "ami-091124c3965bce679"
    instance_type = "t3.micro"

    tags = {
        Name = "SnowydayEC2"
    }
}