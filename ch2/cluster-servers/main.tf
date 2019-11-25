provider "aws" {
  region = "us-west-2"
}


variable "server_port" {
  description = "The port the webserver will use for HTTP requests"
  type        = number
  default     = 8080
}


# Allow inbound TCP traffic on $SERVER_PORT
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


# Get the default VPC
data "aws_vpc" "default" {
  default = true
}

# Get the subnet ID from the default VPC
data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.defaut.id
}


# Launch Configuration
resource "aws_launch_configuration" "tf_cluster" {
  image_id        = "ami-06d51e91cea0dac8d" #=> Ubuntu 18.04LTS
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.tf_webserver_dmz.id]
  user_data       = <<-EOF
                    #!/bin/bash
                    echo "Terraform Cluster" > index.html
                    nohup busybox httpd -f -p ${var.server_port} &
                    EOF
  lifecycle {
    create_before_destroy = true
  }
}


# ASG for Launch Configuration
resource "aws_autoscaling_group" "tf_autoscale" {
  launch_configuration = aws_launch_configuration.tf_cluster.name
  vpc_zone_identifier  = data.aws_subnet_ids.default.ids

  min_size = 2
  max_size = 10

  tag {
    key                 = "Name"
    value               = "terraform-asg-tf_cluster"
    propagate_at_launch = true
  }
}

