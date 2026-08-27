# The data source reads instances in whichever region the provider points at,
# so the region here decides what comes back.
provider "aws" {
  region = "us-east-1"
}

# Fetches details of the EC2 instances running in that region. Comes back empty
# if there are none.
data "aws_instances" "example" {}