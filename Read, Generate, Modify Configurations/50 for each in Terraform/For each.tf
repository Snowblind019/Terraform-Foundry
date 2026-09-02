# Example 1: for_each with a set.
#
# set(string), not set(strings). The plural fails on init with an invalid type
# specification error.
variable "user_names" {
  type    = set(string)
  default = ["alice", "bob", "john", "james"]
}

resource "aws_iam_user" "this" {
  # Reads the four names out of the variable and builds a separate IAM user
  # resource for each one behind the scenes. Adding a fifth name to the list
  # above is all it takes to get a fifth user, no new block.
  for_each = var.user_names

  # On a set there are no key value pairs, so each.key and each.value return
  # the same item. Swapping this to each.key plans as no changes. value is the
  # clearer one to use here.
  name = each.value
}

# Example 2: for_each with a map. Comment the block above and uncomment this
# one to run it.
#
# variable "my-map" {
#   default = {
#     key  = "value"
#     key1 = "value1"
#   }
# }
#
# resource "aws_instance" "web" {
#   for_each = var.my-map
#
#   # A map has both halves available, so each.value takes the value side and
#   # each.key takes the key side. Plan shows two to add: ami value with Name
#   # tag key, and ami value1 with Name tag key1.
#   ami           = each.value
#   instance_type = "t3.micro"
#
#   tags = {
#     Name = each.key
#   }
# }