variable "db_password" {
  # No quotes. type = "string" errors saying the quoted form is from
  # Terraform 0.11 and earlier, is deprecated, and will be removed later.
  type = string

  validation {
    # Boolean expression. True and the plan carries on, false and it stops
    # with the message below.
    #
    # length measures whatever value ends up assigned to the variable, from
    # wherever it came: the default, tfvars, the CLI prompt, a -var flag.
    condition = length(var.db_password) >= 12

    # Shown in the CLI when the condition fails. admin1234 is 9 characters,
    # so entering that at the prompt returns this.
    error_message = "Length of Database Password must be equal to or greater than 12 characters"
  }
}