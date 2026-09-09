# This resource creates nothing in AWS. It exists purely to hold the apply open long
# enough to observe the state lock, which otherwise comes and goes too fast to see.

resource "time_sleep" "wait_100_seconds" {
  # 100 seconds gives you a window to check the working directory for
  # terraform.tfstate.lock.info and to run a second command from another terminal
  # against the locked state.
  create_duration = "100s"
}

# Docs: https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep.html

# Run 1, watching the lock file:
#   terraform init
#   terraform apply -auto-approve
#
# While the apply is waiting out the timer, terraform.tfstate.lock.info exists in the
# working directory. It contains a lock ID and the user holding the lock. When the
# apply completes, Terraform releases the lock and the file is removed automatically.
#
# Run 2, triggering the error:
#   (delete terraform.tfstate)
#   terraform apply -auto-approve
#   then, from a second terminal tab while the first is still running:
#   terraform plan
#
# The second command fails immediately with "Error acquiring the state lock", saying the
# process cannot access the file because another process has locked a portion of it.
# Once the first apply finishes and the lock file is gone, the same terraform plan runs
# without error.

# Note on the two lock files in this directory. .terraform.lock.hcl is the dependency
# lock file for provider versions and has nothing to do with state locking. It is
# present the whole time. terraform.tfstate.lock.info is the state lock and only exists
# during a write operation.

# This is the local backend's locking mechanism specifically. Other backends lock
# differently, and not all of them lock at all, so the backend's documentation has to be
# checked before it is used in production. Consul and S3 both state that they support
# state locking.