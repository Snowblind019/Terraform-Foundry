provider "aws" {
  region = "ap-south-1"
}

# One resource block, three instances. Without count this would be three
# separate blocks, each needing its own unique local name.
resource "aws_instance" "myec2" {
  ami           = "ami-00c39f71452c08778"
  instance_type = "t2.micro"
  count         = 3

  # Every copy gets this same tag, which is the limitation the video is making
  # a point of. All three show up in the console named payments-system.
  tags = {
    Name = "payments-system"
  }
}

# Left commented out on purpose. This is the failure demo: three users, one
# name, and IAM names are unique per account. Applying it creates user index 0,
# errors on 1 and 2, and leaves the state partially applied with one real user
# to clean up. Uncomment only if reproducing it deliberately.
#
# resource "aws_iam_user" "this" {
#   name  = "payments-user"
#   count = 3
# }
