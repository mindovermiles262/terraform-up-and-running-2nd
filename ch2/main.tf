provider "aws" {
  region = "us-west-2"
}

resource "aws_instance" "example" {
  ami             = "ami-0c5204531f799e0c6"   #=> Amazon Linux 2
  instance_type   = "t3.nano"
  tags = {
    Name = "Terraform Example"
  }
}

