module "ecs_cluster" {
  source                = "../../modules/ecs-cluster"
  name                  = var.name
  log_group_name_prefix = var.log_group_name_prefix
  log_retention_in_days = var.log_retention_in_days
  tags                  = var.tags
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

resource "aws_service_discovery_private_dns_namespace" "this" {
  name        = local.service_discovery_namespace_name
  description = "Private DNS namespace for ${var.name} components"
  vpc         = local.vpc_id
  tags        = var.tags
}
