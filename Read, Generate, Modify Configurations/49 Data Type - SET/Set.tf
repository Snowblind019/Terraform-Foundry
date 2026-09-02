# List version. Duplicates are kept and each item has an index, so the
# repeated "hello" stays and can be pulled out by position.
#
# variable "my-list" {
#   type    = list
#   default = ["hello", "world", "hello"]
# }
#
# output "mylist" {
#   value = var.my-list
# }
#
# Swapping the output to var.my-list[0] returns the item at index 0.

# Set version. set(string) rather than plain set: leaving the element type off
# errors on plan saying the set type requires one argument specifying the
# element type.
#
# Duplicates are dropped silently, no error. Passing
# ["hello", "world", "hello"] here stores only hello and world.
#
# Order is not tracked either. Moving john to the front and re-running plan
# comes back with no changes. Doing the same reorder on the list above does
# show as a change, since the index is part of what a list stores.
variable "my-set" {
  type    = set(string)
  default = ["alice", "bob", "john"]
}

output "myset" {
  value = var.my-set
}