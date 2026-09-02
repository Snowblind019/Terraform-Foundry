# Remote-exec provisioner lab.
#
# Two blocks are needed inside the resource, a connection block telling
# Terraform how to log into the server, and the remote-exec block holding
# the commands to run on it.
#
# AMI is for us-east-1. Replace it if applying in another region.

resource "aws_instance" "myec2" {
   ami = "ami-04e5276ebb8451442"
   instance_type = "t2.micro"

   # The key pair the instance is created with. This is the key pair name
   # in AWS, no .pem extension here. Without this there is no key to
   # authenticate against later.
   key_name = "terraform-key"

   # Security group created manually in the console, with inbound SSH on
   # port 22 so Terraform can connect, and HTTP on port 80 for nginx.
   vpc_security_group_ids = ["sg-0edf854d7112cfbf4"]

 # ssh for Linux. winrm is the option for a Windows server.
 #
 # user depends on the image, ec2-user is the default for Amazon Linux.
 #
 # private_key takes the contents of the key, not a path, so the file
 # function loads it. Passing the filename directly fails with
 # "Failed to read ssh private key: no key found".
 #
 # self.public_ip is the public IP of this instance once it is created.
 connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key  = file("./terraform-key.pem")
    host     = self.public_ip
  }

 # These run on the server, not locally. sudo is needed because ec2-user
 # has no administrative privilege, and nginx binds to port 80.
 provisioner "remote-exec" {
    inline = [
      "sudo yum -y install nginx",
      "sudo systemctl start nginx",
    ]
  }
}