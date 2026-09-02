# 47 Resource Dependencies

Terraform decides on its own what order to create resources in. When one resource actually has to exist before another, `depends_on` is how you say so.

Files in this folder:

- `dependency.tf`

Docs:

- https://developer.hashicorp.com/terraform/language/meta-arguments/depends_on

---

## The requirement

An application runs on an EC2 instance, and that application has to write its data to external storage before it can initialize. So two resources are needed:

- the external storage, an S3 bucket here, though it could be any storage
- the EC2 instance the application runs on

Building this by hand, the order is obvious. Create the S3 bucket first so the storage is sitting there ready, then create the EC2 instance second, because the application on it needs somewhere to write to the moment it starts.

## Why the order is a problem in Terraform

The `dependency.tf` file declares both resources:

```hcl
resource "aws_instance" "example" {
  ami           = "ami-0e449927258d45bc4"
  instance_type = "t2.micro"
}

resource "aws_s3_bucket" "example" {
  bucket = "kplabs-demo-s3-007"
}
```

Nothing in that code tells Terraform the two are related. Running `terraform apply` against it gives no guarantee the bucket comes first. Terraform might build the EC2 instance first and the bucket second, or the other way round, and it can go either way between runs.

If the instance comes up first, the application starts, looks for its external storage, does not find it, and errors out. That is the situation to avoid.

## depends_on

`depends_on` tells Terraform to finish everything it is going to do on the dependency object before it starts on the object declaring the dependency. It takes a list, so multiple addresses can go in it.

```hcl
resource "aws_instance" "example" {
  ami           = "ami-0e449927258d45bc4"
  instance_type = "t2.micro"
  depends_on    = [aws_s3_bucket.example]
}
```

The value is the resource address of the bucket, `aws_s3_bucket.example`. Type first, then the local name. With that in place Terraform knows the instance depends on the bucket and builds them in that order.

## Order of creation

`terraform plan` shows two to add. Running `terraform apply -auto-approve`, the output goes in order:

1. S3 bucket created
2. EC2 instance created, and only after the bucket finishes

That ordering holds every run once `depends_on` is there.

## Order of deletion

Destroy reverses it, so dependencies do not get broken on the way down. Running `terraform destroy -auto-approve`:

1. EC2 instance destroyed
2. S3 bucket deleted, and only after the instance is gone

Same reasoning as creation, just backwards. The thing that depends on the bucket has to be out of the way before the bucket itself can go.

## Note on the bucket name

Bucket names are unique across every AWS account, not just your own. `kplabs-demo-s3-007` already exists in the instructor's account, so it needs changing to something else before this will apply.

## Commands used

```sh
terraform apply -auto-approve

terraform destroy -auto-approve
```