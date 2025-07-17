output "target_group" {
  description = "A list containing the pair of target group resources (`aws_lb_target_group`) used for blue-green deployment"
  value       = aws_lb_target_group.this
}
