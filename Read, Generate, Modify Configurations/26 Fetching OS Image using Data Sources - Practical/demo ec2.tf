provider "aws" {
  region = "ap-south-1"
}

# Queries AWS for an AMI instead of having one hardcoded. Whatever region the
# provider points at is the region this searches, so the same code works
# anywhere without edits.
#   most_recent, if the filter matches more than one image, take the newest
#   owners, only images published by Amazon
#   filter on name, which OS and build to match, with a wildcard on the tail
# The wildcard covers the date at the end of the AMI name, which changes every
# time Amazon republishes the image with new patches.
# amd64 in the name matters: the arm64 build of this image will not run on
# t2.micro.
data "aws_ami" "myimage" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# image_id is the attribute on the data source that holds the AMI ID. This is
# the reference that replaces the hardcoded value.
resource "aws_instance" "web" {
  ami           = data.aws_ami.myimage.image_id
  instance_type = "t2.micro"
}