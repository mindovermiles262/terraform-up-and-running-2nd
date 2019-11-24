provider "aws" {
  region = "us-west-2"
}


resource "aws_security_group" "webserver_dmz_8080" {
  name = "terraform-webserver-8080"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "webserver" {
  ami                     = "ami-06d51e91cea0dac8d"   #=> Ubuntu 18.04LTS
  instance_type           = "t2.micro"
  vpc_security_group_ids  = [aws_security_group.webserver_dmz_8080.id]

  user_data = <<-EOF
#!/bin/bash
echo "Terraform Life" > index.html
nohup busybox httpd -f -p 8080 &
EOF

  tags = {
    Name = "Terraform Example"
  }
}

