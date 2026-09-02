# Map version. Comment this out to run the object block below.
#
# Plain map takes string values. Swap to map(number) and every value has to be
# a number: {"Name"="Zeal", "Age"="32","Location"="India"} then errors with a
# number required, while {"Name"="12", "Age"="32","Location"="45"} passes. The
# restriction applies to the values, not the keys.
#
# No structure is declared either way, so any number of key value pairs is
# accepted.
#
# variable "my-map" {
#   type = map
# }
#
# output "variable_value" {
#   value = var.my-map
# }

# Object version. Each attribute gets its own type, which is why the structure
# has to be written out.
#
# type = object on its own fails with an invalid type specification error
# saying the object type requires one argument specifying the attribute types
# as a map.
#
# Quoting the attribute names, as in "Name" = string, fails with object
# constructor map keys must be attribute names. No quotes on the keys here.
variable "my-object" {
  type = object({Name = string, userID = number})
}

# {"Name"="Zeal", "userID"=1234} is accepted.
# {"Name"="Zeal", "userID"="hello"} errors, a number is required.
# Adding an extra pair the object does not declare, such as email, does not
# error. It is discarded during type conversion and never shows in the output.
output "variable_value" {
  value = var.my-object
}