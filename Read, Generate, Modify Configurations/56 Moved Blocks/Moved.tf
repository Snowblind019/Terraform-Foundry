# Originally this was named database_firewall. Renaming the local name on its
# own makes Terraform plan a destroy and recreate, since it reads the changed
# address as a different resource.
resource "aws_security_group" "payment_database_firewall" {
  name = "db_firewall"
}

# The moved block stops that. Terraform treats the object already tracked at
# the old address as belonging to the new one.
#
# The plan after adding this shows nothing to add, change or destroy, but one
# operation still pending: writing the new address into the state file, which
# still holds the old name until apply runs. Plan after that returns no
# changes.
moved {
  from = aws_security_group.database_firewall
  to   = aws_security_group.payment_database_firewall
}