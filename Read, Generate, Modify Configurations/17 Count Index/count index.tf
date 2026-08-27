provider "aws" {
  region = "ap-south-1"
}

# Same three instances as the last lab, but the name tag now ends in the index
# number. count.index is unique per copy and starts at 0, so this applies as
# payments-system-0, payments-system-1, payments-system-2.
# The ${} is needed here because the index is being embedded inside a string.
resource "aws_instance" "myec2" {
  ami           = "ami-00c39f71452c08778"
  instance_type = "t2.micro"
  count         = 3

  tags = {
    Name = "payments-system-${count.index}"
  }
}

# This is the block that failed in the previous lab, now fixed. IAM usernames
# are unique per account, so three copies of one hardcoded name errored out
# after creating index 0. Appending count.index gives each copy its own name.
resource "aws_iam_user" "this" {
  name  = "payments-user-${count.index}"
  count = 3
}

# The numbered version works but the names are still generic. A list variable
# plus count.index lets me supply my own names instead.
variable "users" {
  type    = list
  default = ["alice", "bob", "johncorner", "james", "mrA"]
}

# var.users[count.index] pulls one name out of the list per copy: index 0 is
# alice, 1 is bob, 2 is johncorner. No quotes and no ${} here, because this is
# a direct reference to the variable rather than text with a value dropped in.
# The list has five names but count is 3, so only the first three get used.
resource "aws_iam_user" "that" {
  name  = var.users[count.index]
  count = 3
}