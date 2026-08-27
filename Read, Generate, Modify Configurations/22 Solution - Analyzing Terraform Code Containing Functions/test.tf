# Scratch file used while working through the challenge. Not real config, just
# a place to paste each function and write down what the console returned.
# Renamed to test.tf.bak before the apply so Terraform ignores it.

# The map from the lookup docs example
{
    a = "ay"
    b = "bee"
}

# lookup(map, key) with the map from var.ami and the key from var.region
# Output: ami-08a0d1e16fc3f61ea
lookup({"us-east-1" = "ami-08a0d1e16fc3f61ea","us-west-2" = "ami-0b20a6f09484773af","ap-south-1" = "ami-0e1d06225679bc1c5"},"us-east-1")

# length(list) with the values from var.tags
# Output: 2
length(["firstec2","secondec2"])

# element(list, index) with the values from var.tags
# Output: secondec2 at index 1, firstec2 at index 0
element(["firstec2","secondec2"],1)

# formatdate(spec, timestamp) with the string timestamp() returned
# Output: 17 Jun 2024 17:51 UTC
formatdate("DD MMM YYYY hh:mm ZZZ", "2024-06-17T17:51:34Z")

# The challenge block with every function replaced by what it computed to.
# This is what the code actually builds.
resource "aws_instance" "app-dev" {
   ami = "ami-08a0d1e16fc3f61ea"
   instance_type = "t2.micro"
   count = 2

   tags = {
     Name = element(var.tags,count.index)
     CreationDate = "17 Jun 2024 17:51 UTC"
   }
}