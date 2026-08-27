provider "aws" {
  region = "us-east-1"
}

# aws_instance, singular. Reads back one existing instance rather than creating
# one. The filter is how the instance gets picked, here anything carrying the
# tag Team with the value Production.
data "aws_instance" "example" {
  filter {
    name   = "tag:Team"
    values = ["Production"]
  }
}