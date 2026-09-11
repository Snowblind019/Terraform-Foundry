# rds.tf
#
# Section 6, lab 3.
#
# NOTE: there is no video or transcript for this lab. The comments below explain
# what the code does, read off the code itself. Nothing here is quoted from an
# instructor.
#
# The point of the file: the database password is not written into the Terraform
# configuration. It is read at apply time from a file kept outside the folder
# rds.tf lives in, so it does not sit in the same directory as the code and does
# not get committed with it.

provider "aws" {
  region  = "us-east-1"
  access_key = "YOUR-KEY"
  secret_key = "YOUR-KEY"

# WARNING: the provider block above has no closing brace in the supplied code, so
# this file will not parse as given. A } is needed before the resource block.
# Left as supplied rather than silently corrected.
#
# access_key and secret_key are hardcoded placeholders. Either replace them or
# remove both lines and let Terraform pick credentials up from the environment or
# the AWS config file, which is what every other lab in this section does.

resource "aws_db_instance" "default" {
  allocated_storage    = 5
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "mydb"
  username             = "foo"

  # file() reads the contents of rds_pass.txt at apply time and returns them as a
  # string. The ../ means one directory up from where rds.tf sits, which is the
  # point: the password file is deliberately kept outside the Terraform folder.
  #
  # This keeps the password out of the .tf file. It does not keep it out of the
  # state file, same as the sensitive parameter in lab 02.
  password             = file("../rds_pass.txt")

  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot = "true"
}