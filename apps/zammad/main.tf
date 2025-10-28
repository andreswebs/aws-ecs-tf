module "ecs_cluster" {
  source                = "../../modules/ecs-cluster"
  name                  = var.name
  capacity_providers    = local.ecs_cluster_capacity_providers
  log_group_name_prefix = var.log_group_name_prefix
  log_retention_in_days = var.log_retention_in_days
  tags                  = var.tags
}

resource "aws_security_group" "proxy" {
  name        = "${var.name}-proxy"
  description = "${var.name} proxy"
  vpc_id      = local.vpc_id

  revoke_rules_on_delete = true

  tags = merge(var.tags, {
    Name = "${var.name}-proxy"
  })
}

resource "aws_vpc_security_group_egress_rule" "proxy" {
  security_group_id = aws_security_group.proxy.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"

  description = "Allow all egress"

  tags = merge(var.tags, {
    Name = "${var.name}-proxy"
  })
}

resource "aws_vpc_security_group_ingress_rule" "from_alb" {
  security_group_id            = aws_security_group.proxy.id
  ip_protocol                  = "tcp"
  from_port                    = local.zammad_nginx_port
  to_port                      = local.zammad_nginx_port
  referenced_security_group_id = var.lb_security_group_id

  description = "Allow HTTP"

  tags = {
    Name = "${var.name}-from-alb"
  }
}

resource "aws_security_group" "backend" {
  name        = "${var.name}-backend"
  description = "${var.name} backend"
  vpc_id      = local.vpc_id

  revoke_rules_on_delete = true

  tags = merge(var.tags, {
    Name = "${var.name}-backend"
  })
}

resource "aws_vpc_security_group_egress_rule" "backend" {
  security_group_id = aws_security_group.backend.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"

  description = "Allow all egress"

  tags = merge(var.tags, {
    Name = "${var.name}-backend"
  })
}

resource "aws_vpc_security_group_ingress_rule" "websocket_from_proxy" {
  security_group_id            = aws_security_group.backend.id
  ip_protocol                  = "tcp"
  from_port                    = local.zammad_websocket_port
  to_port                      = local.zammad_websocket_port
  referenced_security_group_id = aws_security_group.proxy.id

  description = "Allow HTTP to ${local.zammad_websocket_container_name}"

  tags = {
    Name = "${var.name}-${local.zammad_websocket_container_name}-from-proxy"
  }
}

resource "aws_vpc_security_group_ingress_rule" "railsserver_from_proxy" {
  security_group_id            = aws_security_group.backend.id
  ip_protocol                  = "tcp"
  from_port                    = local.zammad_railsserver_port
  to_port                      = local.zammad_railsserver_port
  referenced_security_group_id = aws_security_group.proxy.id

  description = "Allow HTTP to ${local.zammad_railsserver_container_name}"

  tags = {
    Name = "${var.name}-${local.zammad_railsserver_container_name}-from-proxy"
  }
}

resource "aws_service_discovery_private_dns_namespace" "this" {
  name        = local.service_discovery_namespace_name
  description = "Private DNS namespace for ${var.name} components"
  vpc         = local.vpc_id
  tags        = var.tags
}

resource "aws_lb_target_group" "this" {
  name             = var.name
  vpc_id           = local.vpc_id
  target_type      = "ip"
  protocol         = "HTTP"
  protocol_version = "HTTP1"
  port             = local.zammad_nginx_port

  health_check {
    enabled             = true
    protocol            = "HTTP"
    port                = "traffic-port"
    path                = "/"
    matcher             = "200-499"
    interval            = 10
    timeout             = 5
    unhealthy_threshold = 2
    healthy_threshold   = 2
  }

  tags = merge(var.tags, {
    Name = var.name
  })
}

resource "aws_lb_listener_rule" "this" {
  listener_arn = var.lb_listener_arn
  priority     = var.lb_lister_rule_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  condition {
    host_header {
      values = [
        var.app_domain_name,
      ]
    }
  }

  tags = merge(var.tags, {
    Name = var.name
  })
}
