# vault.tf
#
# Section 6, video 4: the Vault provider demo.
#
# NOTE: the filename is a guess. The transcript garbles it and never spells it
# out. The code below is exactly as supplied.

# The Vault provider needs to know where Vault is running. 127.0.0.1 is the
# loopback address and 8200 is Vault's default port, so this is Vault running on
# the same machine as Terraform, which is how the demo is set up. Point it at the
# real address of your own Vault instance otherwise.
provider "vault" {
  address = "http://127.0.0.1:8200"
}

# Reads an existing secret out of Vault rather than creating anything. The path is
# the same one shown in the Vault console: the secret engine mounted at "secret",
# then the secret name "db_creds".
#
# This is where the demo failed the first time. The path had been written as
# secret/db-creds with a hyphen, and terraform apply returned:
#   No secret found at secret/db-creds
# Changing the hyphen to an underscore fixed it.
data "vault_generic_secret" "demo" {
  path = "secret/db_creds"
}

# Only here to confirm the secret actually came back. data_json holds the whole
# secret payload as JSON, which in the demo was the username admin and the
# password password123 entered in the Vault console.
#
# sensitive means the apply prints nothing for this output. The value was
# confirmed by opening the state file instead, where it sits in the outputs
# section in plain text. That is the exam pointer for this video: anything read
# from or written to Vault through Terraform gets persisted in state, so the
# state file has to be secured.
#
# Note sensitive is written here as the quoted string "true" rather than the bare
# keyword true. Terraform converts it, so both work. Left as supplied.
output "vault_secrets" {
  value = data.vault_generic_secret.demo.data_json
  sensitive = "true"
}