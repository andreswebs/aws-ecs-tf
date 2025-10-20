output "security_group" {
  description = "The `aws_security_group` resource"
  value       = aws_security_group.this
}

output "subnet_group" {
  description = "The `aws_db_subnet_group` resource"
  value       = aws_db_subnet_group.this
}

output "availability_zones" {
  description = "The availability zones of the subnets in the DB subnet group"
  value       = [for s in data.aws_subnet.this : s.availability_zone]
}

output "subnets" {
  description = "List of subnet data objects"
  value       = local.subnets
}
