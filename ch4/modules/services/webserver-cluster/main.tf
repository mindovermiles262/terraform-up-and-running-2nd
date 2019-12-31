data "terraform_remote_state" "tf_db" {
  backend = "s3"

  config = {
    bucket = "aduss-tfur-state"
    key    = "staging/data-stores/mysql/terraform.tfstate"
    region = "us-west-2"
  }
}


terraform {
  backend "s3" {
    bucket = var.db_remote_state_bucket
    key    = var.db_remote_state_key
    region = "us-west-2"

    dynamodb_table = "aduss_tfur_locks"
    encrypt        = true
  }
}

locals {
  http_port    = 80
  any_port     = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  all_ips      = ["0.0.0.0/0"]
}


# Allow inbound TCP traffic on $SERVER_PORT
resource "aws_security_group" "tf_webserver_dmz" {
  description = "TF Webserver DMZ. Allow ${var.server_port}/TCP"
  name        = "${var.cluster_name}-${var.server_port}-server-sg"

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
  name        = "${var.cluster_name}-alb-sg"

  ingress {
    from_port   = local.http_port
    to_port     = local.http_port
    protocol    = local.tcp_protocol
    cidr_blocks = local.all_ips
  }

  # Allow all outbound for LB Health Checks
  egress {
    from_port   = local.any_port
    to_port     = local.any_port
    protocol    = local.any_protocol
    cidr_blocks = local.all_ips
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


data "template_file" "user_data" {
  template = file("${path.module}/user-data.sh")

  vars = {
    server_port = var.server_port
    db_fqdn     = data.terraform_remote_state.tf_db.outputs.db_address # output names match the outputs.tf names in mysql/outputs.tf
    db_port     = data.terraform_remote_state.tf_db.outputs.db_port
  }
}


# Launch Configuration
resource "aws_launch_configuration" "tf_cluster" {
  image_id        = "ami-06d51e91cea0dac8d" #=> Ubuntu 18.04LTS
  instance_type   = var.instance_type
  security_groups = [aws_security_group.tf_webserver_dmz.id]
  user_data       = data.template_file.user_data.rendered
  lifecycle {
    create_before_destroy = true
  }
}


# ASG for Launch Configuration
resource "aws_autoscaling_group" "tf_autoscale" {
  launch_configuration = aws_launch_configuration.tf_cluster.name
  vpc_zone_identifier  = data.aws_subnet_ids.default.ids

  min_size = var.min_size
  max_size = var.max_size

  # Deploy instances to 'tf_tg' target group
  target_group_arns = [aws_lb_target_group.tf_tg.arn]

  # Use the target group's health check to determine if node is alive
  health_check_type = "ELB"

  tag {
    key                 = "Name"
    value               = var.cluster_name
    propagate_at_launch = true
  }
}


# Create Application Load Balancer (ALB)
resource "aws_lb" "tf_alb" {
  name               = "${var.cluster_name}-alb"
  load_balancer_type = "application"
  subnets            = data.aws_subnet_ids.default.ids
  security_groups    = [aws_security_group.tf_alb.id]
}


# Create 'listener' for ALB
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.tf_alb.arn
  port              = local.http_port
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
  name     = "${var.cluster_name}-asg-target"
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

