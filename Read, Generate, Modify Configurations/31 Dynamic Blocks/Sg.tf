# List of ports the security group should allow in. The dynamic block below
# walks this list, so adding a port here is the only edit needed to add a rule.
variable "sg_ports" {
  type    = list(number)
  default = [8200, 8201, 8300, 9200, 9500]
}

resource "aws_security_group" "demo_sg" {
  name = "sample-sg"

  # Generates one ingress block per item in var.sg_ports.
  #
  # "ingress" after dynamic is the nested block being produced.
  # for_each is what gets walked.
  # content is the body of a single generated block.
  # ingress.value is the current list item, so the port changes each pass
  # while protocol and cidr_blocks stay the same for every rule.
  dynamic "ingress" {
    for_each = var.sg_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

# This is what the resource looked like before the dynamic block. Same result,
# but every rule is a hand written copy of the one above it. Kept here for
# reference, at 40 or 50 rules this is the thing worth avoiding.
#
# resource "aws_security_group" "demo_sg" {
#   name = "sample-sg"
#
#   ingress {
#     from_port   = 8200
#     to_port     = 8200
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#
#   ingress {
#     from_port   = 8201
#     to_port     = 8201
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#
#   ingress {
#     from_port   = 8300
#     to_port     = 8300
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#
#   ingress {
#     from_port   = 9200
#     to_port     = 9200
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#
#   ingress {
#     from_port   = 9500
#     to_port     = 9500
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }