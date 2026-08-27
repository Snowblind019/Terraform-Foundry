# Reads a file from the local file system. Nothing gets created, the contents
# just end up in state.
# path.module resolves to the directory this code lives in, so the full path
# does not have to be written out.
data "local_file" "foo" {
  filename = "${path.module}/demo.txt"
}

# The data source stores what it read in the content attribute. This prints it
# to the CLI on apply instead of leaving it buried in the state file.
output "data" {
  value = data.local_file.foo.content
}