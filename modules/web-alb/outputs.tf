output "lb" {
  value = aws_lb.this
}

output "sg" {
  value = aws_security_group.this
}

output "listener" {
  value = {
    http  = aws_lb_listener.http
    https = aws_lb_listener.https
  }
}
