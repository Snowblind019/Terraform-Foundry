resource "aws_instance" "example" {
  ami           = "ami-0e449927258d45bc4"
  instance_type = "t2.micro"

  # This is the implicit dependency. The value is not a literal ID, it is the
  # id attribute read off the security group resource below.
  #
  # Terraform sees that it cannot fill this in until the group exists, so it
  # creates the group first, fetches the id, computes it in here, then creates
  # the instance. No depends_on needed.
  #
  # In plan, both the group's id and this argument show as known after apply,
  # since neither value exists until the group is created.
  vpc_security_group_ids = [aws_security_group.prod.id]
}

resource "aws_security_group" "prod" {
  # prod is the local name used in the resource address above.
  # production-sg is the name the group gets in AWS.
  name = "production-sg"
}