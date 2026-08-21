# The default is the floor, not a normal source. It is only used when nothing
# else supplies a value. Every other source in this folder beats it.
variable "instance_type" {
  default = "t2.micro"
}
