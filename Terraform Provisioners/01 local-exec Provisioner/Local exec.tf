# Local-exec provisioner lab.
#
# The provisioner is written inside the resource block. Placing it outside
# the resource does not work.
#
# AMI is for us-east-1. Replace it if applying in another region.

resource "aws_instance" "myec2" {
   ami = "ami-04e5276ebb8451442"
   instance_type = "t2.micro"

   # local-exec runs the command on the machine Terraform is running on,
   # not on the EC2 instance that was just created.
   #
   # self refers to this resource, aws_instance.myec2, so self.private_ip
   # is the private IP of the instance created above. Swapping it for
   # self.public_ip writes the public address instead.
   #
   # server_ip.txt does not exist before the apply, the redirect creates it.
   provisioner "local-exec" {
    command = "echo ${self.private_ip} >> server_ip.txt"
   }
}