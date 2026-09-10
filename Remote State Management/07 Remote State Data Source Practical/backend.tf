# Without this block the state would be written locally, and the security team would
# have nothing remote to read from. The remote backend is a prerequisite for the whole
# use case, not just good practice here.

terraform {
  backend "s3" {
    # FILL THIS IN. Left empty in the course code on purpose. The video used
    # kplabs-networking-bucket-demo, created by hand in the console beforehand.
    # S3 bucket names are unique across every AWS account, so use your own.
    bucket = ""

    # Stored at the root of the bucket. If the bucket had folders you would path
    # into them here.
    key = "eip.tfstate"

    # Has to match where the bucket was actually created.
    region = "us-east-1"
  }
}

# These same three values get copied into the security team's data.tf. That is how the
# security team locates this state file. If you change the bucket name here, change it
# there too.
#
# Docs: https://developer.hashicorp.com/terraform/language/settings/backends/s3