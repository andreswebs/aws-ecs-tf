resource "aws_lb" "this" {
  name               = var.cluster_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb.id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false
}

resource "aws_route53_record" "this" {
  zone_id = var.route53_zone_id
  name    = var.cluster_name
  type    = "A"

  alias {
    name                   = aws_lb.this.dns_name
    zone_id                = aws_lb.this.zone_id
    evaluate_target_health = true
  }
}

resource "aws_lb_target_group" "ui" {
  name        = "${var.cluster_name}-ui"
  vpc_id      = var.vpc_id
  protocol    = "HTTP"
  target_type = "ip"
  port        = 16686

  health_check {
    protocol = "HTTP"
    port                = 16687
    path = "/"

  }

}

resource "aws_lb_listener" "ui_https" {
  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ui.arn
  }
}

resource "aws_lb_listener" "ui_http" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
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
