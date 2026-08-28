# First of two HCL files in this folder. Nothing special about it being
# "first" other than the name, Terraform loads both regardless.
resource "local_file" "foo" {
  content  = "Hello from KPLABS!"
  filename = "${path.module}/kplabs.txt"
}