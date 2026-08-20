# The central file. Change a value here and every resource using it picks up
# the change on the next apply, without touching the main config file.
#
# The name of this file matters by convention, not by function. Any .tf file
# works, but variables.tf is the standard name and is what other people will
# look for.

variable "vpn_ip" {
  default = "200.20.30.50/32"

  # Worth filling in. Someone new reading this has no way to know what the
  # variable is for from the name alone.
  description = "This is a VPN Server Created in AWS"
}

variable "app_port" {
  default = "8080"
}

variable "ssh_port" {
  default = "22"
}

variable "ftp_port" {
  default = "21"
}