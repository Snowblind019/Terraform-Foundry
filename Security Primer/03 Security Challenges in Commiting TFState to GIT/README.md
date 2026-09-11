# 03 - HashiCorp Vault and the Vault Provider

Section 6: Security Primer

Covers two videos: the HashiCorp Vault overview, and the Vault provider in Terraform. They
share one topic and one code set, so they are documented together.

## Part 1: HashiCorp Vault overview

Vault stores secrets securely and puts access management around them. The kind of secrets
meant here are database passwords, AWS access and secret keys, API tokens, encryption keys,
and similar.

The problem it addresses is that in a lot of organizations these values end up sitting in
someone's notepad.

### Dynamic secrets

The feature the video spends most of its time on. Vault generates credentials on request and
hands them back with a lease, then deletes them when the lease expires. The user has to come
back and request a fresh set.

The instructor's example from a previous job: developers requesting access to a developer
database got a username and password from Vault that was valid for 24 hours. The next day
they had to request new credentials. Rotating on that cadence cuts down the window for a
database breach or a leak of confidential data.

### GUI demo

Vault started as a CLI-only tool, which made it a harder thing to learn. It now has a GUI,
and the demo runs through it.

Secret engines shown, all from the console:

- **AWS.** A developer clicks Generate and Vault returns an access key and a secret key for
  local testing. Vault deletes them later depending on the configuration, so the next day the
  developer generates a new pair.
- **Database.** A request returns a username and password with a lease duration of 1 hour.
  After that they are removed. The developer either regenerates or renews the lease before it
  expires.
- **Linux instance login.** Vault supplies a username and a key the developer uses to log in.

Beyond dynamic secrets, the console demo also shows:

- **Encryption.** An application that needs encrypt and decrypt functionality can call Vault
  instead of building the logic itself. Plain text in, encrypted data out, and Vault decrypts
  it again later.
- Hashing data and random data generation, mentioned but not demonstrated.

### The operational argument

With 200 to 300 developers in an organization all needing database credentials, the database
administrator spends a large amount of time just issuing them. Once Vault is integrated with
the backends, it takes that over, and access management in general moves to Vault.

The video defers the detail of each Vault feature to subsequent videos.

## Part 2: The Vault provider

Terraform has hundreds of providers. Vault is one of them, and it lets Terraform read from,
write to, and configure a Vault instance.

The use case: a secret in Vault at `secret/db_creds` holding a database username and
password. If you want to create a database whose credentials are the ones held in Vault, you
inject them into Terraform rather than writing them into the configuration.

The configuration has three parts:

1. A `vault` provider block with the `address` of the running Vault instance.
2. A `vault_generic_secret` data source pointing at the path where the secret lives,
   `secret/db_creds`.
3. An output referencing that data source, so the fetched value can be confirmed.

### Walkthrough

In the Vault console, a secret was created under `secret` called `db_creds`, with the secret
data holding a username of `admin` and a password of `password123`. The contents can be read
back directly from Vault given the right permission.

In Terraform:

```
terraform init
```

This downloads the Vault provider.

```
terraform apply
```

First attempt failed:

```
No secret found at secret/db-creds
```

A typo. The path was written with a hyphen rather than an underscore. Corrected to
`secret/db_creds` and applied again.

The apply succeeded. The output showed nothing because `sensitive` was set on the output
block. The fetched value was confirmed instead by opening the Terraform state file, where the
outputs section held `admin` and `password123`.

That is the shape of the real use case: when creating a database or an RDS instance, the
username and password come from Vault rather than from the configuration.

### The AWS secret engine with Terraform

Vault's AWS engine generates IAM user credentials. Clicking Generate in the console returns
an access key and a secret key.

Terraform can be pointed at those, which means no access key or secret key is hardcoded in
the Terraform configuration. Terraform connects to Vault, fetches the current access and
secret key, and uses them for its AWS operations.

## Exam pointer

Interacting with Vault from Terraform means any secret you read or write ends up persisted in
the Terraform state file. Reading a secret from Vault and passing it to another service puts
that secret in state. The state file has to be secured, otherwise the secrets are exposed
there.

## Scope note

This is a Terraform course, not a Vault course, so configuring Vault from scratch is not
covered. The instructor points at a separate dedicated Vault course based on the HashiCorp
Vault Associate certification for that.