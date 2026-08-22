# No provider block and no resources in this one, nothing is created in AWS.
# The variable plus the output is enough to see what the type constraint
# accepts and what it rejects.

variable "my-map" {
  type = map

  # With the default set, apply stops prompting. Delete the default block to go
  # back to typing the value at the prompt, which has to be in the form
  # {"team"="payments", "location"="US"}.
  default = {
    Name = "Alice"
    Team = "Payments"
  }
}

output "variable_value" {
  value = var.my-map
}
