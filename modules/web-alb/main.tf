data "aws_subnet" "selected" {
  id = var.public_subnet_ids[0]
}

locals {
  vpc_id  = data.aws_subnet.selected.vpc_id
  sg_name = "${var.name}${var.security_group_name_suffix}"
}

resource "aws_security_group" "this" {
  vpc_id = local.vpc_id

  revoke_rules_on_delete = true

  tags = merge(var.tags, {
    Name = local.sg_name
  })

  name = local.sg_name
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.this.id
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"

  description = "Allow HTTP"

  tags = merge(var.tags, {
    Name = format("%s-http", local.sg_name)
  })
}

resource "aws_vpc_security_group_ingress_rule" "allow_https" {
  security_group_id = aws_security_group.this.id
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"

  description = "Allow HTTPS"

  tags = merge(var.tags, {
    Name = format("%s-https", local.sg_name)
  })
}

resource "aws_lb" "this" {
  name               = var.name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.this.id]
  subnets            = var.public_subnet_ids
  enable_http2       = true

  enable_deletion_protection = var.enable_deletion_protection

  tags = merge(var.tags, {
    Name = var.name
  })
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
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
  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.acm_certificate_arns[0]

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      status_code  = 404
      message_body = "Not Found"
    }
  }
}

resource "aws_lb_listener_certificate" "this" {
  count           = length(var.acm_certificate_arns) - 1
  certificate_arn = var.acm_certificate_arns[count.index + 1]
  listener_arn    = aws_lb_listener.https.arn
}
