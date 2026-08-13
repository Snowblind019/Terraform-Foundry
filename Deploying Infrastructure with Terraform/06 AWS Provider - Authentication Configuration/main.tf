 /*Region and nothing else. No access_key, no secret_key, no file paths.
 Terraform falls back to ~/.aws/credentials and ~/.aws/config, which is where
 `aws configure` writes them, so this works identically on any machine that has
 the CLI set up. Nothing secret ends up in the repo and nobody has to
 standardize where their home directory lives.*/
provider "aws" {
  region = "us-west-2"
}
/*
 Simple resource to prove auth is working. Creating an IAM user touches a
 different API than EC2 does, so if this applies cleanly the credentials are
 genuinely being picked up.*/
resource "aws_iam_user" "snowy_demo_user" {
  name = "snowy-demo-user"
}
/*
 --- alternatives, kept for reference, not active ---

 Explicit file paths. Works, but hardcoding a home directory breaks the moment
 someone else clones the repo. Note both field names are plural and both take
 a list, so the brackets and the quotes are required.

 provider "aws" {
   shared_config_files      = ["/home/snowy/.aws/config"]
   shared_credentials_files = ["/home/snowy/.aws/credentials"]
   profile                  = "customprofile"
 }

 Assuming a role instead of using a user's keys directly.

 provider "aws" {
   region = "us-west-2"

   assume_role {
     role_arn     = "arn:aws:iam::123456789012:role/TerraformRole"
     session_name = "terraform"
   }
 }

 Environment variables need no provider config at all, and they win over the
 shared files if both are present:
   export AWS_ACCESS_KEY_ID="..."
   export AWS_SECRET_ACCESS_KEY="..."
   export AWS_REGION="us-west-2"
*/