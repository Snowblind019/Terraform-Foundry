# Nothing to do with logging itself, just something small to run plan and apply
# against while testing the log levels. Creates foo.txt in this directory.
resource "local_file" "foo" {
  content  = "foo!"
  filename = "${path.module}/foo.txt"
}