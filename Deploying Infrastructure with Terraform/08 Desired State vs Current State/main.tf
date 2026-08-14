provider "aws" {
  region = "us-west-2"
}

# The desired state. Whatever is written here wins over whatever is running.
#
# Drift walkthrough:
#   terraform apply        -> desired and current now match
#   terraform plan         -> "No changes"
#   [in the console: stop the instance, resize it to t3.small, start it]
#   terraform plan         -> "~ update in place", proposing t3.small back to t3.micro
#   terraform apply        -> stops, resizes, starts. About a minute of downtime.
#
# Then delete or comment out the whole resource block below and run apply again,
# NOT destroy. Terraform sees a resource in state with no matching config and
# destroys it. Removing code is an instruction to tear things down.
resource "aws_instance" "WinterdayEC2" {
  ami           = "ami-091124c3965bce679"
  instance_type = "t3.micro"

  tags = {
    Name = "WinterdayEC2"
  }
}

# Two symbols to watch for in plan output, they are not the same thing:
#   ~   update in place    -> modified where it stands (instance_type)
#   -/+ must be replaced   -> destroyed and rebuilt, new ID (ami, subnet_id)
# The replacement case prints "# forces replacement" next to the attribute that
# caused it. That line is the one worth reading before typing yes.
#
# If the manual change was the correct one and the config is what's wrong:
#   terraform apply -refresh-only
# writes reality into state without touching infrastructure. The config still
# needs fixing afterwards or the next normal apply reverts it again.
