output "alb_dns_name" {
  description = "The DNS name of the 'tf_alb' ALB"
  value       = aws_lb.tf_alb.dns_name
}

