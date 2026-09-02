# Base version, for comparison. At the top level this data source failing is a
# hard error, and local_file.foo never gets created because of it.
#
# data "http" "example" {
#   url = "https://google1231233dsd.com"
# }

check "website_checker" {
  # Scoped data source. At most one per check block, and nothing outside the
  # block can reference it. If it errors, and this URL will since the domain
  # is nonsense, Terraform reports a warning rather than failing the run.
  data "http" "example" {
    url = "https://google1231233dsd.com"
  }

  # Same condition and error_message shape as validation, precondition and
  # postcondition. The difference is severity: a failed assert is a warning,
  # so the run carries on and local_file.foo below still gets created.
  assert {
    condition     = data.http.example.status_code == 200
    error_message = "Website is not running. Please check"
  }
}

resource "local_file" "foo" {
  content  = "Hi"
  filename = "${path.module}/foo.txt"
}