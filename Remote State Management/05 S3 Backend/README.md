# 05 - S3 Backend

Section 5: Remote State Management

## Documentation referenced

- https://developer.hashicorp.com/terraform/language/backend/s3

## What this video covers

The previous videos established that Terraform supports a wide variety of backends. This
one takes S3 as a worked example, mainly to show the shape of adding any backend.

The S3 backend stores the state file in a specific S3 bucket. Once an S3 backend, or any
other backend, is configured, the state file is not stored locally. It goes to that
backend instead.

## The shape of a backend block

Every backend uses the same outer structure. Inside a `terraform` block, you declare
`backend` with the backend's name, and then the arguments specific to that backend.

For the local backend covered earlier, the block was `backend "local"` with a `path`
argument. For S3, the `terraform` block and the `backend` keyword stay the same, the name
changes from `local` to `s3`, and the arguments inside change to match.

For S3 you need to say which bucket the state file goes into, which region that bucket is
in, and so on.

## File layout

The base configuration is `sg.tf`, creating a simple security group:

```hcl
resource "aws_security_group" "prod" {
  name = "production-sg"
}
```

The backend configuration went into a separate file, `backend.tf`. As mentioned in the
earlier backend video, putting it in `sg.tf` works perfectly well as far as Terraform is
concerned. The reason for the separate file is practical: in a project with 40 or 50 files,
the filename alone tells you where the backend configuration lives.

## Creating the bucket

The bucket has to exist before Terraform can use it. In the AWS console, go to the S3
service, then Buckets, then create a bucket.

The bucket name has to be unique across all AWS accounts, not just yours. The instructor
used `kplabs-demo-bucket-007` and noted he was hoping nobody else had taken it. After
creation, the console shows the bucket name and the region it was created in, which are
the two values that go into the backend configuration.

## The backend configuration

```hcl
terraform {
  backend "s3" {
    bucket       = "kplabs-demo-bucket-007"
    key          = "production.tfstate"
    region       = "us-east-1"
    use_lockfile = "true"
  }
}
```

You must change the bucket name to one you own. The name in this config will not work for
anyone else.

### The arguments

- `bucket` is which bucket holds the state file. This matters because an AWS account can
  have hundreds of buckets.
- `region` is where that bucket lives, `us-east-1` here.
- `key` is the path to the state file inside the bucket. If your bucket has subfolders you
  can give the full path through them. Kept simple here, so `production.tfstate` lands at
  the root of the bucket.

### State locking

The S3 backend documentation states that this backend supports state locking, and that it
is enabled by setting `use_lockfile` to `true`. The documentation for the argument itself
describes it as whether to use a lock file for locking the state file, and notes that the
default is `false`.

So locking is off unless you turn it on. The instructor added the argument explicitly for
that reason, and mentioned that if this argument is not present when you look at the docs
later, the available options are listed on the same page.

## Running it

```sh
terraform init
terraform apply -auto-approve
```

`terraform init` has to be run first once a backend is specified. The output shows it
initializing the backend.

The apply created the security group and completed normally.

## The result

After the apply, there is no `terraform.tfstate` file in the `kplabs-terraform` project
folder. Refreshing the folder confirms it: nothing local.

The state is in the S3 bucket instead. Refreshing the bucket in the console shows
`production.tfstate` sitting in it, at the path set by the `key` argument.

## Generalizing

The same workflow applies to any other backend. For a Kubernetes backend or an azurerm
backend, the `terraform` block stays the same, the backend name changes, and the arguments
inside change to whatever that backend requires. The overall shape does not change.

## Commands used

```sh
terraform init
terraform apply -auto-approve
```