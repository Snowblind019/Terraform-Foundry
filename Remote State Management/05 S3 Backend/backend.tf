# S3 backend. Once this is in place the state file is written to the bucket instead of
# to the project folder.
#
# The bucket has to already exist. It was created by hand in the AWS console before
# running any of this, not by Terraform.

terraform {
  backend "s3" {
    # Which bucket holds the state. An AWS account can have hundreds of buckets, so
    # this is not optional.
    #
    # CHANGE THIS. S3 bucket names are unique across every AWS account, not just yours,
    # so this exact name belongs to the course and will not work for you.
    bucket = "kplabs-demo-bucket-007"

    # Path to the state file inside the bucket. If the bucket has subfolders you can
    # give the full path through them. This one has no subfolders, so the file lands
    # at the root of the bucket as production.tfstate.
    key = "production.tfstate"

    # Region the bucket was created in. The console shows this on the bucket after
    # you create it.
    region = "us-east-1"

    # State locking is off by default on this backend. The documentation lists the
    # default for this argument as false, so locking only happens because it is set
    # here explicitly.
    use_lockfile = "true"
  }
}

# Docs: https://developer.hashicorp.com/terraform/language/backend/s3
#
# The outer shape is identical for every backend: a terraform block, a backend block
# with the backend's name, and arguments specific to that backend. Swapping to
# kubernetes or azurerm changes the name and the arguments, nothing else.
#
# Run terraform init after adding or changing this block, before any apply.