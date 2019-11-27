output "db_address" {
  description = "RDS DB Endpoint FQDN"
  value       = aws_db_instance.tf_db.address
}


output "db_port" {
  description = "RDS DB Listening Port"
  value       = aws_db_instance.tf_db.port
}
