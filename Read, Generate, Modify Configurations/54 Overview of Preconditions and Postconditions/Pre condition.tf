# Fetches the characteristics of one instance type. free_tier_eligible is the
# attribute the precondition below reads.
data "aws_ec2_instance_type" "example" {
  instance_type = "t3.micro"
}

# Temporary output used to check what the data source returns. t2.micro comes
# back true, m5.large comes back false. Remove once the precondition is in.
output "instance_type" {
  value = data.aws_ec2_instance_type.example.free_tier_eligible
}

resource "aws_instance" "example" {
  instance_type = "t2.micro"
  ami           = "ami-066784287e358dad1"

  lifecycle {

    precondition {
      # free_tier_eligible is already a boolean, so no comparison is needed.
      # True means carry on, false means stop before anything is created.
      condition     = data.aws_ec2_instance_type.example.free_tier_eligible
      error_message = "Instance Type is not part of free tier"
    }

    postcondition {
      # self refers to this resource block. Only usable in a postcondition,
      # since a precondition runs before there are any attributes to read.
      #
      # As written this is the deliberately failing version: it demands an
      # empty value, and the instance will have one. Apply creates the
      # instance, then errors with resource postcondition failed. Use != ""
      # for the check that actually passes.
      condition     = self.public_dns == ""
      error_message = "Public IPV4 or DNS is mandatory for this server"
    }
  }
}