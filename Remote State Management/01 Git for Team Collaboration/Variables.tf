# Declared with no type and no default. The value has to come from somewhere else,
# which in this demo is terraform.tfvars. Keeping the declaration and the value in
# two separate files is what makes the "older version of variables" warning in the
# video concrete: if a team member pulls a stale terraform.tfvars, the same code
# builds different infrastructure.

variable "sg_name" {}