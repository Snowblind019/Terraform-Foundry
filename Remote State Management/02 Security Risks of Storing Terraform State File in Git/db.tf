# This file exists to prove one thing: whatever value Terraform resolves for the
# password ends up in terraform.tfstate as plain text. Both versions below produce
# the same result in state.

resource "aws_db_instance" "default" {
  allocated_storage = 10
  db_name           = "mydb"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"
  username          = "foo"

  # --- Version 2: password read from a separate file ---
  # The objection this answers is "I won't hardcode the secret, I'll pull it in from
  # elsewhere, so it won't land in state." It still lands in state. The file function
  # reads the file and returns its contents as the computed value, and the computed
  # value is what gets written out.
  #
  # The path argument has to be in double quotes. Leaving them off is the error the
  # instructor hit on his first terraform plan after making this edit.
  #
  # Note also that terraform plan displays this as a sensitive value rather than the
  # actual string. That masking is only in the plan output. The state file shows it
  # in the clear.
  password = file("outside-folder/pass.txt")

  # --- Version 1: password hardcoded ---
  # The starting state of the lab. Applied first, state file inspected, password found
  # in plain text, then destroyed before switching to the file function above.
  # password = "foobarbaz#321"

  parameter_group_name = "default.mysql8.0"

  # Lets terraform destroy complete without being asked for a final snapshot. Relevant
  # here because the database was created and destroyed twice during the video.
  skip_final_snapshot = true
}

# Run with:
#   terraform init
#   terraform apply -auto-approve
#   (inspect terraform.tfstate, scroll down, find the password)
#   terraform destroy -auto-approve
#
# Create and destroy each took roughly four minutes. This is a real RDS instance and
# can be charged for.