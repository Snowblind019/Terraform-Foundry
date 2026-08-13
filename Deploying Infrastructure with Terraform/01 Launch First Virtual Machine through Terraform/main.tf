# The provider block has to be here at least once before terraform init will
# pull anything down. Empty braces means I'm letting region and credentials
# come from the environment (AWS_REGION / AWS_PROFILE) instead of hardcoding
# them into a file that git tracks.
provider "aws" {}

# resource = "make this exist"
# aws_instance = the resource type, fixed, comes straight from the provider docs
# WinterdayEC2 = the local name, mine to choose, only used by Terraform internally
resource "aws_instance" "WinterdayEC2" {
  # AMI IDs are region specific. This one is valid in my region only. If you
  # change regions you have to look up the equivalent ID for that region.
  ami           = "ami-091124c3965bce679"
  instance_type = "t3.micro"

  # The local name above does NOT show up in the AWS console. The Name column
  # in the EC2 list is just a tag with the key "Name", so if I want it labelled
  # I have to set it here.
  tags = {
    Name = "WinterdayEC2"
  }
}
