# 02 - Why the Terraform State File Should Not Be Committed to Git

Section 5: Remote State Management

## What this video covers

The previous video said `terraform.tfstate` should stay out of the Git repository and
deferred the reason. This video is that reason.

The framing up front: this is not a security risk in 100% of cases. There are specific
cases where committing the state file leads to a security risk, and those are what the
video walks through.

## The core problem

The Terraform state file can contain secrets in plain text. Passwords, tokens, and
similar values. The instructor showed a screenshot of a state file with a password
sitting in it unobscured.

Once that file is committed, everyone with access to the repository can read those
secrets. The specific risk called out is accidental exposure if the repository is public,
shared, or compromised.

The realistic version of this is permissions creep. Repository access in most
organizations is granted well beyond what is actually necessary. A new hire joins, gets
read access to the repo as a matter of course, and now has the production database
password and critical production tokens. That becomes a database breach if that person's
laptop is compromised, since the repo gets pulled down onto it.

Where the state file should go instead is covered in later videos in this section.

## Part 1: Password hardcoded in the config

The demo uses a single file, `db.tf`, creating an RDS instance in AWS. A database
resource needs a password, so the resource block includes `username` and `password`
directly.

```hcl
resource "aws_db_instance" "default" {
  allocated_storage    = 10
  db_name              = "mydb"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = "foo"
  password             = "foobarbaz#321"
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
}
```

Applied with:

```sh
terraform init
terraform apply -auto-approve
```

The instructor flagged that you do not have to follow along here, because RDS resources
can incur charges. He ran it only for demonstration. Creation took roughly four minutes.

Once the apply finished, he opened `terraform.tfstate`, scrolled down, and the database
password was there in plain text.

Torn down with:

```sh
terraform destroy -auto-approve
```

Destroy also took roughly four minutes.

## Part 2: The `file` function does not help

The second half addresses an objection the instructor expected: what if you do not put
the password in `db.tf` at all, and instead pull it in from a separate file using
Terraform's `file` function?

The `file` function reads a file at a given path and returns its contents as the computed
value.

He created `outside-folder/pass.txt` containing just the password:

```
foobarbaz#321
```

Then removed the hardcoded password from `db.tf` and replaced it with a `file` call:

```hcl
password = file("outside-folder/pass.txt")
```

### Error hit during the demo

The first `terraform plan` after this edit produced an error. The fix was wrapping the
path argument in double quotes. After that, `terraform plan` ran clean.

### What the plan showed versus what the state showed

In the `terraform plan` output, the password was displayed as a sensitive value rather
than the actual string. That is the part that misleads people. The instructor's point is
that the plan output hiding it does not mean the state file hides it.

Applied again:

```sh
terraform apply -auto-approve
```

After roughly four minutes the database was created. Opening `terraform.tfstate` and
scrolling down showed the password in plain text again, exactly as before, even though
it was never hardcoded in the configuration file.

The conclusion: fetching a secret from somewhere else does not keep it out of state.
Whatever value Terraform resolves ends up written to the state file.

Torn down with:

```sh
terraform destroy -auto-approve
```

## Closing point

An objection the instructor addressed directly: someone looks at their current state file,
sees no sensitive values in it, and decides the rule does not apply to them. His answer is
that this is a statement about today. Six months or a year from now you will be building
new infrastructure for the organization, and that infrastructure may well carry sensitive
values. The state file will pick them up, and by then committing state is an established
habit in the repo.

So the recommendation stands as a default: keep the state file out of Git.

## Commands used

```sh
terraform init
terraform apply -auto-approve
terraform plan
terraform destroy -auto-approve
```

## Cost note

This lab creates a real `db.t3.micro` RDS instance. It was created and destroyed twice in
the video, each operation taking around four minutes. `skip_final_snapshot = true` is set
on the resource, which is what allows the destroy to complete without prompting for a
final snapshot.