output "cluster" {
  description = "The ECS cluster resource (``)"
  value       = aws_ecs_cluster.this
}

output "log_group" {
  description = "The log group resource (`aws_cloudwatch_log_group`)"
  value       = aws_cloudwatch_log_group.this
}
