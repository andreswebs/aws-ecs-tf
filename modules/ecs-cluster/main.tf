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

/*
TODO: research how to enable a flexible capacity provider approach
and strategy

The cluster must allow different setups:

Fargate only (including spot), EC2 provider - research managed instances

Refs:
- <https://aws.amazon.com/blogs/aws/announcing-amazon-ecs-managed-instances-for-containerized-applications/>


resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name       = aws_ecs_cluster.this.name
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    base              = 1
    weight            = 100
  }
}
*/
