resource "aws_ecs_cluster" "this" {
  name = var.name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge(var.tags, {
    Name = var.name
  })
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "${var.log_group_name_prefix}${var.name}"
  retention_in_days = var.log_retention_in_days
}

locals {
  log_group_name = aws_cloudwatch_log_group.this.name
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name       = aws_ecs_cluster.this.name
  capacity_providers = var.capacity_providers

  dynamic "default_capacity_provider_strategy" {
    for_each = var.default_capacity_provider_strategies
    iterator = s
    content {
      capacity_provider = s.value.capacity_provider
      base              = s.value.base
      weight            = s.value.weight
    }
  }

}
