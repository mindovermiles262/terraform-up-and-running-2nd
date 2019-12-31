output "alb_dns_name" {
  description = "The DNS name of the 'tf_alb' ALB"
  value       = aws_lb.tf_alb.dns_name
}

output "alb_security_group_id" {
  description = "The ID of the Security Group attached to the load balancer"
  value       = aws_security_group.tf_alb.id
}

