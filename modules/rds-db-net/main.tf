data "aws_subnet" "this" {
  for_each = toset(var.subnet_ids)
  id       = each.value
}

locals {
  subnets = [for id, subnet in data.aws_subnet.this : subnet]
}

resource "aws_security_group" "this" {
  name        = var.db_security_group_name
  description = var.db_security_group_description
  vpc_id      = local.subnets[0].vpc_id

  tags = merge(var.tags, {
    Name = var.db_security_group_name
  })
}

resource "aws_vpc_security_group_egress_rule" "this" {
  count             = length(var.egress_rules_ipv4)
  security_group_id = aws_security_group.this.id
  description       = var.egress_rules_ipv4[count.index].description
  ip_protocol       = var.egress_rules_ipv4[count.index].ip_protocol
  from_port         = var.egress_rules_ipv4[count.index].from_port
  to_port           = var.egress_rules_ipv4[count.index].to_port
  cidr_ipv4         = var.egress_rules_ipv4[count.index].cidr_ipv4

  tags = merge(var.tags, {
    Name = var.egress_rules_ipv4[count.index].name
  })
}

resource "aws_vpc_security_group_ingress_rule" "this" {
  count             = length(var.ingress_rules_ipv4)
  security_group_id = aws_security_group.this.id
  description       = var.ingress_rules_ipv4[count.index].description
  ip_protocol       = var.ingress_rules_ipv4[count.index].ip_protocol
  from_port         = var.ingress_rules_ipv4[count.index].from_port
  to_port           = var.ingress_rules_ipv4[count.index].to_port
  cidr_ipv4         = var.ingress_rules_ipv4[count.index].cidr_ipv4

  tags = merge(var.tags, {
    Name = var.ingress_rules_ipv4[count.index].name
  })
}

resource "aws_db_subnet_group" "this" {
  name       = var.db_subnet_group_name
  subnet_ids = local.subnets[*].id
  tags = merge(var.tags, {
    Name = var.db_subnet_group_name
  })
}
