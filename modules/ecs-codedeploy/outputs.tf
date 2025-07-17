output "app" {
  value       = aws_codedeploy_app.this
  description = "The `aws_codedeploy_app` resource"
}

output "deployment_group" {
  value       = aws_codedeploy_deployment_group.this
  description = "The `aws_codedeploy_deployment_group` resource"
}
