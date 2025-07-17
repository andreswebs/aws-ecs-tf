resource "aws_lb_target_group" "this" {
  count       = 2
  name        = "${var.target_group_name}-${count.index + 1}"
  target_type = "ip"
  port        = var.target_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group#health_check
  health_check {
    enabled             = true
    port                = "traffic-port"
    path                = "/"
    matcher             = "200-499"
    interval            = 10
    timeout             = 5
    unhealthy_threshold = 2
    healthy_threshold   = 2
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = var.load_balancer_arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = var.load_balancer_arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[0].arn
  }

  lifecycle {
    ignore_changes = [default_action]
  }

  depends_on = [aws_lb_target_group.this]
}
