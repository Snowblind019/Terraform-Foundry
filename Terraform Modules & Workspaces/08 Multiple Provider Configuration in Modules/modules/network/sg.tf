# modules/network/sg.tf
#
# Child module with two security groups that need to end up in two
# different regions.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"

      # Step 2 of 3. This declares that the module expects a second,
      # aliased AWS provider configuration to be handed to it under the
      # name aws.prod. Without this line the module has no aws.prod to
      # refer to, and plan fails saying the provider configuration is not
      # present.
      #
      # The name here has to match the key used in the providers map in the
      # root module.
      configuration_aliases = [aws.prod]
    }
  }
}

# No provider argument, so this inherits the default provider from the root
# module and lands in us-east-1.
resource "aws_security_group" "dev" {
  name = "dev-sg"
}

resource "aws_security_group" "prod" {
  name = "prod-sg"

  # Step 3 of 3. aws.prod was bound to the root module's aws.mumbai
  # configuration, so this security group gets created in ap-south-1
  # instead of us-east-1.
  provider = aws.prod
}