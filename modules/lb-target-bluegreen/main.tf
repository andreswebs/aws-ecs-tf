resource "aws_lb_target_group" "this" {
  count            = 2
  name             = "${var.name}-${count.index + 1}"
  vpc_id           = var.vpc_id
  target_type      = var.target_type
  protocol         = var.protocol
  protocol_version = var.protocol_version
  port             = var.target_port

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group#health_check
  health_check {
    enabled             = var.health_check.enabled
    protocol            = var.health_check.protocol
    port                = var.health_check.port
    path                = var.health_check.path
    matcher             = var.health_check.matcher
    interval            = var.health_check.interval
    timeout             = var.health_check.timeout
    unhealthy_threshold = var.health_check.unhealthy_threshold
    healthy_threshold   = var.health_check.healthy_threshold
  }
}
