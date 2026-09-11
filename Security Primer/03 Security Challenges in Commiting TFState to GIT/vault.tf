# vault.tf
#
# Section 6, video 3: the Vault provider demo.
#
# NOTE: no code block was pasted for this file. Everything below is reconstructed
# from what the transcript describes on screen: a vault provider block with an
# address, a vault_generic_secret data source pointing at secret/db_creds, and an
# output called vault_secret referencing the data_json attribute with sensitive
# set. The filename is also a guess; the transcript garbles it.

# The Vault provider needs to know where Vault is running. The transcript says the
# IP address of the Vault instance goes here. Replace with whatever address your
# own Vault listens on.
provider "vault" {
  address = "http://VAULT-ADDRESS:8200"
}

# Reads an existing secret out of Vault rather than creating anything. The path is
# the same path shown in the Vault console: the secret engine mounted at "secret",
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
# secret payload, which in the demo was the username admin and the password
# password123 entered in the Vault console.
#
# sensitive = true means the apply prints nothing for this output. The value was
# confirmed by opening terraform.tfstate instead, where it sits in the outputs
# section in plain text. That is the exam pointer for this video: anything read
# from or written to Vault through Terraform is persisted in state, so the state
# file has to be secured.
output "vault_secret" {
  value     = data.vault_generic_secret.demo.data_json
  sensitive = true
}