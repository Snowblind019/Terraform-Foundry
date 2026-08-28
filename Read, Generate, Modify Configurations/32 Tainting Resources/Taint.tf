# The course version of this file hardcodes access_key and secret_key here.
# Leaving them out so credentials come from the AWS CLI configuration instead
# of sitting in a file that goes to GitHub.
provider "aws" {
  region = "us-east-1"
}

# Plain instance, nothing special about it. The point of the lab is not what
# this builds, it is being able to throw it away and rebuild it on demand.
#
# Once this is applied, a second terraform apply reports no changes, because
# the configuration and state still agree. To force a rebuild anyway:
#
#   terraform apply -replace="aws_instance.myec2"
#
# That destroys this instance and creates a new one from the same AMI, which
# is how to get back to the original state after someone has made manual
# changes on the box.
resource "aws_instance" "myec2" {
  ami           = "ami-00c39f71452c08778"
  instance_type = "t2.micro"
}