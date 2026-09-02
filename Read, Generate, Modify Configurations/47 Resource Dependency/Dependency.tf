resource "aws_instance" "example" {
  ami           = "ami-0e449927258d45bc4"
  instance_type = "t2.micro"

  # Without this, nothing in the config links the instance to the bucket, so
  # Terraform is free to build them in either order. The application on this
  # instance writes to the bucket when it initializes, so the bucket has to
  # exist first.
  #
  # Takes a list of resource addresses. Type first, then local name.
  depends_on = [aws_s3_bucket.example]
}

resource "aws_s3_bucket" "example" {
  # Bucket names are unique across all AWS accounts, not just this one. This
  # name is already taken in the instructor's account, so change it before
  # applying.
  bucket = "kplabs-demo-s3-007"
}