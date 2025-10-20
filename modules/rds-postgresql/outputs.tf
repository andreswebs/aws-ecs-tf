output "db_instance" {
  description = "The complete RDS instance resource"
  value       = aws_db_instance.this
}

output "db_parameter_group" {
  description = "The complete DB parameter group resource"
  value       = aws_db_parameter_group.this
}

output "read_replicas" {
  description = "The complete read replica resources (if created)"
  value       = aws_db_instance.read_replica
}

output "read_replica_endpoints" {
  description = "List of read replica endpoints"
  value       = aws_db_instance.read_replica[*].endpoint
}

output "cloudwatch_dashboard" {
  description = "The complete CloudWatch dashboard resource"
  value       = aws_cloudwatch_dashboard.this
}
