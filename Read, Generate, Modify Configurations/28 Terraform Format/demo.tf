# Deliberately badly indented. Valid code, plan and apply run fine, it just
# reads poorly. Run terraform fmt against it to see the difference.
resource "local_file" "this" {
content = "kplabs"
    filename = "${path.module}/kplabs.txt"
}