# Separate file for the backend configuration, which is the practice the instructor
# recommended: keep it out of the files where resources are defined. Terraform itself
# does not require this.

terraform {
  # The local backend is what Terraform falls back to when no backend is declared, so
  # declaring it explicitly changes nothing on its own. The point of doing it is to get
  # access to its arguments.
  backend "local" {
    # Overrides the default state file name and location. Without this, the file is
    # terraform.tfstate in the project folder. With it, the file is prod.tfstate.
    # The path does not have to stay inside the project folder either.
    path = "prod.tfstate"
  }
}

# Adding this block means terraform init has to be run again before the next apply.
#
# This is still local state, so it does not solve either problem from the earlier
# videos. The file still sits on one laptop, and a teammate still cannot reach it.
# Solving that means a remote backend such as S3, Consul, GCS or AzureRM, which also
# brings in the authentication and state locking considerations covered at the end of
# the video. Those are demonstrated in later videos in this section.
#
# Snippet source: https://developer.hashicorp.com/terraform/language/backend/local