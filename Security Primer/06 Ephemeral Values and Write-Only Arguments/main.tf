# main.tf
#
# Section 6, video 6: ephemeral values and write-only arguments.
#
# The video moves through two states of this file. The base state is kept below as
# a commented block, since it exists to demonstrate the problem rather than as a
# step toward the final version.
#
# -----------------------------------------------------------------------------
# BASE STATE - the problem being demonstrated.
#
# A normal resource block generates the password, a normal password argument
# passes it to RDS, and an output exposes it with sensitive set.
#
# After terraform apply -auto-approve, the CLI shows db_password as a sensitive
# value, but terraform.tfstate holds the plain text password in two places: the
# outputs section, and the result attribute on the random_password resource. The
# second one is the important one, because it happens with or without the output
# block.
#
# resource "random_password" "db_password" {
#   length           = 16
#   override_special = "!#$%&*()-_=+[]{}<>:?"
# }
#
# resource "aws_db_instance" "default" {
#   allocated_storage    = 10
#   db_name              = "mydb"
#   engine               = "mysql"
#   engine_version       = "8.0"
#   instance_class       = "db.t3.micro"
#   username             = "foo"
#   password          = random_password.db_password.result
#   skip_final_snapshot  = true
# }
#
# output "db_password" {
#   value = random_password.db_password.result
#   sensitive = true
# }
# -----------------------------------------------------------------------------


# Same block as above with one word changed: ephemeral instead of resource.
# Ephemeral resources have their own lifecycle and Terraform does not write them
# to state or plan files. Applying with only this block present leaves the state
# file empty.
#
# The registry documents both forms on the same page: a random_password resource,
# and further down an ephemeral random_password.
ephemeral "random_password" "db_password" {
  length           = 16
  override_special = "!#$%&*()-_=+[]{}<>:?"
}


resource "aws_db_instance" "default" {
  allocated_storage    = 10
  db_name              = "mydb"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = "foo"

  # password_wo is the write-only form of the password argument. The aws_db_instance
  # documentation carries a note saying it is available in place of password, and
  # it needs Terraform 1.11.0 or later.
  #
  # Using the plain password argument here would put the value in state, which is
  # the thing being avoided. Reading the value out of the ephemeral resource does
  # not persist it either.
  password_wo          = ephemeral.random_password.db_password.result

  # Required whenever password_wo is used. Leaving it out fails the plan with a
  # missing required argument error.
  #
  # It exists because Terraform cannot see password_wo at all: the value is not in
  # state and not in the plan file, so Terraform has no way to tell whether it
  # changed and cannot produce a diff for it. The version number IS stored in
  # state, so it is the only signal Terraform can act on. Incrementing it is what
  # triggers a new password to be generated and pushed to the resource.
  #
  # The video starts at 1 and ends at 3, having incremented it to show the update
  # cycle.
  password_wo_version  = 3

  skip_final_snapshot  = true
}

# Everything below is the Secrets Manager part, which the video says is not exam
# material. It is there to answer the obvious question: if Terraform generates a
# password it never stores, how do you connect to the database?
#
# The answer is to write the same generated password into Secrets Manager at the
# same time, so it can be retrieved by anyone with permission on that secret.
# Secrets Manager holds it encrypted using KMS.

# The secret itself, an empty container. Shows up in the AWS console under
# Secrets Manager as db_pass.
resource "aws_secretsmanager_secret" "db_password" {
  name = "db_pass"
}

# The value stored in that secret. Same write-only pattern as the RDS resource:
# secret_string_wo takes the value, secret_string_wo_version tracks changes.
#
# Both versions are set to 3, matching password_wo_version above. Incrementing
# both together is what keeps the password in Secrets Manager in sync with the
# password actually set on the database.
resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id                = aws_secretsmanager_secret.db_password.id
  secret_string_wo         = ephemeral.random_password.db_password.result
  secret_string_wo_version = 3
}

# NOTE: this block is in the supplied code but is not shown or discussed anywhere
# in the transcript. Reading it as written, it is an ephemeral read of the secret
# version that was just created, which would be the way to get the password back
# out for use elsewhere in the configuration without it landing in state. Nothing
# in this file consumes it, so as it stands it does nothing.
ephemeral "aws_secretsmanager_secret_version" "db_password" {
  secret_id = aws_secretsmanager_secret_version.db_password.secret_id
}