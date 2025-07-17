output "target_group" {
  description = "A list containing the pair of target group resources (`aws_lb_target_group`) used for blue-green deployment"
  value       = aws_lb_target_group.this
}

output "listener" {
  description = "A map of listener resources (`aws_lb_listener`)"
  value = {
    http  = aws_lb_listener.http
    https = aws_lb_listener.https
  }
}
