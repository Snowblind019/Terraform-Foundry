provider "aws" {}

resource "aws_instance" "WinterdayEC2" {
    ami = "ami-091124c3965bce679"
    instance_type = "t3.micro"

    tags = {
        Name = "WinterdayEC2"
    }
}