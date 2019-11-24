provider "aws" {
  region = "us-west-2"
}


variable "server_port" {
  description = "The port the webserver will use for HTTP requests"
  type        = number
  default     = 8080
}


resource "aws_security_group" "tf_webserver_dmz" {
  description = "TF Webserver DMZ. Allow ${var.server_port}/TCP"
  name        = "terraform-webserver-${var.server_port}"

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "webserver" {
  ami                    = "ami-06d51e91cea0dac8d" #=> Ubuntu 18.04LTS
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.tf_webserver_dmz.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Terraform Life" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF
  tags = {
    Name = "Terraform Example"
  }
}


output "server_public_ip" {
  description = "The Public IP of the TF Web Server"
  value       = aws_instance.webserver.public_ip
}

