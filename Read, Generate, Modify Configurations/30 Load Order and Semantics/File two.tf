# Second file in the same folder, loaded and merged with file-one.tf.
#
# This started out as "foo", the same local name used in file-one.tf, and
# plan errored with "a local_file resource named foo was already declared in
# file-one.tf". Different filename and different content did not help, the
# resource address is what has to be unique across the whole configuration.
# Renaming it to foo2 is what made the plan run.
resource "local_file" "foo2" {
  content  = "Hello!"
  filename = "${path.module}/two.txt"
}