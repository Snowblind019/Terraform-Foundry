# rds.tf
#
# Section 6, video 3, companion code.
#
# NOTE: this file is not shown or discussed in either of the two transcripts for
# this lab. It was supplied alongside them. The comments below explain what the
# code does, not what an instructor said about it.
#
# The idea it demonstrates is the same one the Vault provider video argues for,
# arrived at without Vault: the database password is not written into the
# Terraform configuration. Here it is read at apply time from a file kept outside
# the folder rds.tf lives in, so it never sits in the same directory as the code
# and does not get committed with it.

provider "aws" {
  region  = "us-east-1"
  access_key = "YOUR-KEY"
  secret_key = "YOUR-KEY"

# WARNING: the provider block above has no closing brace in the pasted code, so
# this file will not parse as given. A } is needed before the resource block.
# Left as pasted rather than silently corrected.

resource "aws_db_instance" "default" {
  allocated_storage    = 5
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "mydb"
  username             = "foo"

  # file() reads the contents of rds_pass.txt at apply time and uses it as the
  # password. The ../ means one directory up from where rds.tf sits, which is the
  # point: the password file is deliberately kept outside the Terraform folder.
  #
  # This keeps the password out of the .tf file. It does not keep it out of the
  # state file, same as with the sensitive parameter in the previous lab.
  password             = file("../rds_pass.txt")

  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot = "true"
}