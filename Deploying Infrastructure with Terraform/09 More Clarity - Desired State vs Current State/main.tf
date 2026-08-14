provider "aws" {
  region = "us-west-2"
}

# --- Version A: the minimal block, defaults everywhere ---
#
# Two arguments. AWS fills in the root volume (8 GiB SSD), the security group
# (default), the subnet, the AZ, metadata options, and everything else.
#
# terraform plan on this prints a lot of "(known after apply)". Every one of
# those lines is a decision that got made without me.
#
# The point of the section: apply this, then go into the console and swap the
# security group to something else. Run plan again. It says "No changes."
# Terraform refreshed and saw the new group, it just has nothing in the config
# to compare against, so there's no drift to report. Defaults are not desired
# state, they're the absence of desired state.
resource "aws_instance" "WinterdayEC2" {
  ami           = "ami-091124c3965bce679"
  instance_type = "t3.micro"

  tags = {
    Name = "WinterdayEC2"
  }
}

# --- Version B: the same instance, declared properly ---
#
# Commented out because it references a subnet and security group that don't
# exist in this folder yet. Uncomment once those are defined.
#
# Everything below is now enforced. Change any of it in the console and the next
# plan wants it back. That's the difference between a config that describes the
# instance and one that merely creates it.
#
# resource "aws_instance" "WinterdayEC2_explicit" {
#   ami                    = "ami-091124c3965bce679"
#   instance_type          = "t3.micro"
#   subnet_id              = aws_subnet.main.id
#   vpc_security_group_ids = [aws_security_group.web.id]
#
#   root_block_device {
#     volume_size = 20
#     volume_type = "gp3"
#     encrypted   = true
#   }
#
#   # IMDSv2 required. Left at default this is optional, which is how instance
#   # credentials get pulled through SSRF.
#   metadata_options {
#     http_tokens = "required"
#   }
#
#   tags = {
#     Name = "WinterdayEC2"
#   }
# }

# Note that subnet_id forces replacement rather than updating in place, so
# adding it to an already-applied instance rebuilds the instance. Check the plan
# for "# forces replacement" before applying.
#
# The deliberate opposite of a default is lifecycle.ignore_changes, which tells
# Terraform to set an attribute at creation and then stop caring about it. Same
# end result as omitting it, except it's written down so the next person knows
# it was a choice:
#
#   lifecycle {
#     ignore_changes = [tags["LastPatched"]]
#   }
