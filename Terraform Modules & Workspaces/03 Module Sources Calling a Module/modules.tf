# Referencing a module that lives in a GitHub repository.
#
# The module block plus a source argument is the pattern for every module,
# regardless of where the code is stored. Only the format of the source
# value changes between location types, and the documentation gives the
# exact format for each one:
# https://developer.hashicorp.com/terraform/language/modules/sources

module "ec2" {
  # The GitHub format starts at github.com. Writing this as
  # https://github.com/... is what caused terraform init to fail with
  # "error downloading, no source URL was returned". Dropping the https://
  # made init work.
  source = "github.com/zealvora/sample-kplabs-terraform-ec2-module"

  # If the module had multiple published versions, a version argument
  # would go here to pin one, for example:
  #   version = "18.8.0"
  # Without it the latest code is pulled.
}