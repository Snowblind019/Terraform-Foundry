# 03 - Storing the RDS Password in a Separate File

Section 6: Security Primer

## No video for this lab

There is no transcript or video for this one. The material is a configuration file and a
password file, with a single instruction attached: keep `rds_pass.txt` outside the folder that
`rds.tf` lives in.

Everything below is read off the code itself. Nothing here comes from an instructor, and where
this connects to other labs in the section that is my own reading rather than something that
was stated.

## The files

Two files:

- `rds.tf`, which creates an `aws_db_instance`
- `rds_pass.txt`, holding the password as its only contents

The password is not written into `rds.tf`. It is pulled in at apply time:

```
password = file("../rds_pass.txt")
```

`file()` reads the contents of the path given and returns them as a string. The `../` means
one directory up from wherever `rds.tf` sits, which is the point of the instruction to keep
the password file outside the Terraform folder.

## What this achieves

The password is no longer in the `.tf` file, so it is not in whatever gets committed to
version control along with the configuration, assuming the password file stays outside that
directory.

## What it does not achieve

The password still ends up in `terraform.tfstate` in plain text once applied, the same way it
does with `sensitive = true` in lab 02. `file()` changes where the value is read from, not
where it is written to.

## Notes on the code as supplied

- The `provider "aws"` block is missing its closing brace, so the file will not parse as
  given.
- `access_key` and `secret_key` are hardcoded in the provider block as `YOUR-KEY`
  placeholders. Replace them, or drop both lines and let Terraform pick up credentials from
  the environment or the AWS config file.
- `name` is used on the `aws_db_instance` resource. Other labs in this section use `db_name`
  for the same thing.
- `skip_final_snapshot = "true"` is quoted here. Terraform accepts the string and converts it.

## Cost

`aws_db_instance` creates a real RDS instance. `db.t2.micro` with 5 GB of gp2 storage is small
but not free past the free tier, and RDS instances bill by the hour while they exist. Destroy
when you are done.