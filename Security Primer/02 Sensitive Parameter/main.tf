# main.tf
#
# Section 6, video 2: sensitive parameter, local file demo.
#
# The video moves through four states of this file. All four are kept below, with the
# final one active and the earlier ones commented out, since each stage exists to
# demonstrate a specific behaviour rather than to be a step toward the last one.
#
# -----------------------------------------------------------------------------
# STAGE 1 - baseline. terraform plan prints the content in plain text.
#
# resource "local_file" "foo" {
#   content  = "supersecretpassw0rd"
#   filename = "password.txt"
# }
#
# -----------------------------------------------------------------------------
# STAGE 2 - the value moved into a variable. This does NOT hide anything.
# terraform plan resolves var.password and prints the same string next to content.
# The video runs this on purpose to show the assumption is wrong.
#
# variable "password" {
#   default = "supersecretpassw0rd"
# }
#
# resource "local_file" "foo" {
#   content  = var.password
#   filename = "password.txt"
# }
#
# -----------------------------------------------------------------------------
# STAGE 3 - sensitive on the variable. Now the content attribute shows as
# (sensitive value) in the plan output.
#
# Note the video writes the value quoted as "true" rather than the bare keyword
# true. Both are accepted here; Terraform converts the string. Kept as written.
#
# variable "password" {
#   default   = "supersecretpassw0rd"
#   sensitive = "true"
# }
#
# resource "local_file" "foo" {
#   content  = var.password
#   filename = "password.txt"
# }
#
# -----------------------------------------------------------------------------
# STAGE 4 - the state the file ends in, below.
# -----------------------------------------------------------------------------


# local_sensitive_file is a separate resource type in the local provider that
# treats content as sensitive by default. Only the resource type changed from
# stage 1; the variable was dropped and the password put back inline, and the
# plan still redacts the content.
#
# The local_file documentation carries a note pointing at this resource when the
# file content is sensitive. Not every provider offers a parallel resource like
# this, so the provider docs are the place to check.
resource "local_sensitive_file" "foo" {
  content  = "supersecretpassw0rd"
  filename = "password.txt"
}


# Referencing a sensitive value in an output is rejected outright: terraform plan
# fails, because the output block would put the value on the CLI. Adding
# sensitive = true to the output block is what makes it legal. The apply then
# succeeds and the outputs section reads pass = <sensitive>.
#
# The point of keeping the output at all is the state file. terraform.tfstate has
# an outputs section holding the real value in plain text, and other projects and
# teams read the state file to pull values from there. The sensitive flag only
# covers CLI output and logs; it does not redact the state file.
output "pass" {
  value     = local_sensitive_file.foo.content
  sensitive = true
}