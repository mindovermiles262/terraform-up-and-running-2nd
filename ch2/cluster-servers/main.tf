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


# Allow Inbound 80/TCP to ALB
resource "aws_security_group" "tf_alb" {
  description = "TF ALB DMZ. Allow 80/TCP (HTTP)"
  name        = "terraform-alb-80"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound for LB Health Checks
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Get the default VPC
data "aws_vpc" "default" {
  default = true
}

# Get the subnet ID from the default VPC
data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
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

  # Deploy instances to 'tf_tg' target group
  target_group_arns = [aws_lb_target_group.tf_tg.arn]

  # Use the target group's health check to determine if node is alive
  health_check_type = "ELB"

  tag {
    key                 = "Name"
    value               = "terraform-asg-tf_cluster"
    propagate_at_launch = true
  }
}


# Create Application Load Balancer (ALB)
resource "aws_lb" "tf_alb" {
  name               = "Terraform-UandR-ALB"
  load_balancer_type = "application"
  subnets            = data.aws_subnet_ids.default.ids
  security_groups    = [aws_security_group.tf_alb.id]
}


# Create 'listener' for ALB
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.tf_alb.arn
  port              = 80
  protocol          = "HTTP"

  # Set Default action to return 404
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: Page Not Found"
      status_code  = 404
    }
  }
}


# Create listener rule
resource "aws_lb_listener_rule" "fwd_to_tf_tg" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    field  = "path-pattern"
    values = ["*"]
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tf_tg.arn
  }
}


# Create Target Groups for ASG
resource "aws_lb_target_group" "tf_tg" {
  name     = "terraform-asg-target-group"
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}


output "alb_dns_name" {
  description = "The DNS name of the 'tf_alb' ALB"
  value       = aws_lb.tf_alb.dns_name
}

