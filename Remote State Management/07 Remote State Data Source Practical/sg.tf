# Security team side, step two: use the value fetched from the networking team's state.

resource "aws_security_group" "allow_tls" {
  name = "allow_tls"
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_tls.id

  # The reference reads as: data, then the data source type terraform_remote_state,
  # then vpc which is the local name of the block in data.tf, then outputs, then
  # eip_addr which is the output name declared by the networking team in eip.tf.
  #
  # /32 is appended with interpolation because the output is a bare IP address and AWS
  # expects a CIDR range. Whatever address gets computed picks up the /32.
  #
  # The IP appears nowhere in this folder. It is resolved at plan time by reading the
  # networking team's state file out of S3.
  cidr_ipv4 = "${data.terraform_remote_state.vpc.outputs.eip_addr}/32"

  # Starting version, before the remote state lookup was wired in. A hardcoded
  # placeholder, which is the thing this lab is replacing.
  # cidr_ipv4 = "172.31.20.30/32"

  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}

# Run from the security-team folder:
#   terraform init
#   terraform validate
#   terraform plan
#
# The plan output is where you confirm it worked. cidr_ipv4 should show the actual EIP
# the networking team created, 44.195.111.26 in the video, rather than the placeholder
# or an unresolved value.