# rds.tf
#
# Section 6, video 2: the second half of the demo, showing that the AWS provider
# already redacts some attributes without being told to.
#
# The resource block is the basic usage example copied straight from the
# aws_db_instance documentation, with username and password written inline in
# plain text. terraform init is needed first if the AWS provider plugin is not
# already downloaded in this directory.
#
# On terraform plan:
#   password -> shown as (sensitive value), even though nothing here marks it
#   username -> shown in plain text
#
# The AWS provider carries the logic for this. It applies to resources where a
# secret is obviously present, like RDS, not to every resource type.

resource "aws_db_instance" "default" {
  allocated_storage    = 10
  db_name              = "mydb"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = var.db_user
  password             = "foobarbaz"
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
}

# Hiding the username is not something the provider does for you, so it goes back
# to the variable approach from earlier in the video. After this, terraform plan
# shows the username as a sensitive value too.
#
# Where the line sits between sensitive and not sensitive past the obvious cases
# is left as an organization by organization decision.
variable "db_user" {
  default   = "admin"
  sensitive = true
}