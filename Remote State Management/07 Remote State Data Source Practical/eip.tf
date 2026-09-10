# Networking team side. Creates the elastic IP that the security team will later read
# out of this team's state file.

resource "aws_eip" "lb" {
  domain = "vpc"
}

# This output is what makes the whole lab work. The terraform_remote_state data source
# can only read output values, not resource attributes, so anything another team needs
# has to be declared here explicitly. Without this block the security team has nothing
# to fetch.
#
# The name eip_addr is what the security team references as
# data.terraform_remote_state.vpc.outputs.eip_addr
output "eip_addr" {
  value = aws_eip.lb.public_ip
}

# Run from the networking-team folder:
#   terraform init
#   terraform plan
#   terraform apply -auto-approve
#
# The apply prints the EIP because of the output block. In the video it came out as
# 44.195.111.26, which is the value that shows up again on the security team side.