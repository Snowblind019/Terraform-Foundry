# DigitalOcean is not an official HashiCorp provider, so it has to be declared
# in required_providers before it can be used.
terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
    }
  }
}

provider "digitalocean" {
  token = "your-token-here"
}

# One line, and it reads back the details of the DigitalOcean account the token
# belongs to: email, whether it is verified, droplet and floating IP limits,
# account status. "example" is just a local name, it can be anything.
data "digitalocean_account" "example" {}