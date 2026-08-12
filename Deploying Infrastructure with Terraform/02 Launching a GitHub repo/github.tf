#specifying the terraform provider
terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

#need to specify a PAT so github will have access to my account. 
provider "github" {
  token = "[Redacted PAT]"
}

#calling the resource creation of github repository and naming it test
resource "github_repository" "test" {
  name = "test"
  description = "Creating a github repo with terraform"

  #set the visibility of the repo to private or public.
  visibility = "public"
}