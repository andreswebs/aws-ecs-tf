data "aws_region" "current" {}

data "aws_ami" "ecs_ami_latest" {
  most_recent = true
  filter {
    name   = "name"
    values = ["al2023-ami-ecs-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["amazon"]
}

locals {
  ami_id = data.aws_ami.ecs_ami_latest.id

  user_data = base64encode(templatefile("${path.module}/tpl/userdata.tftpl", {
    cluster_name = var.cluster_name
  }))

  jaeger_ports = {
    ui             = 16686
    collector_http = 14268
  }
}

resource "aws_launch_template" "this" {
  name                   = "ecs-${var.cluster_name}"
  description            = "Launch template for ECS cluster ${var.cluster_name}"
  update_default_version = true

  instance_type = var.instance_type

  monitoring {
    enabled = true
  }

  image_id = local.ami_id

  vpc_security_group_ids = [aws_security_group.instance.id]

  iam_instance_profile {
    name = var.instance_profile_name
  }

  user_data = local.user_data

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "ecs-${var.cluster_name}-node"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "this" {

  name = "ecs-${var.cluster_name}"

  vpc_zone_identifier = var.private_subnet_ids

  desired_capacity = var.cluster_desired_capacity
  max_size         = var.cluster_max_size
  min_size         = var.cluster_min_size

  launch_template {
    id      = aws_launch_template.this.id
    version = aws_launch_template.this.latest_version
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }

  lifecycle {
    ignore_changes = [
      load_balancers,
      target_group_arns,
    ]
  }

}

resource "aws_ecs_capacity_provider" "this" {
  name = var.cluster_name

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.this.arn

    managed_scaling {
      status                    = "DISABLED"
      maximum_scaling_step_size = 1000
      minimum_scaling_step_size = 1
      target_capacity           = 100
    }
  }
}

resource "aws_ecs_cluster" "this" {
  name = var.cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name       = aws_ecs_cluster.this.name
  capacity_providers = [aws_ecs_capacity_provider.this.name]
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/ecs/${var.cluster_name}"
  retention_in_days = var.log_retention_in_days
}

locals {
  container_definitions = templatefile("${path.module}/tpl/container-definitions.json.tftpl", {
    aws_region            = data.aws_region.current.name
    log_group_name        = aws_cloudwatch_log_group.this.name
    jaeger_es_server_urls = var.jaeger_es_server_urls
  })
}

resource "aws_ecs_task_definition" "this" {
  family                   = "jaeger"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn
  container_definitions    = local.container_definitions
}

resource "aws_ecs_service" "this" {
  depends_on      = [aws_lb.this]
  name            = "jaeger-all-in-one"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn

  enable_ecs_managed_tags = true
  enable_execute_command  = true

  scheduling_strategy = "REPLICA"
  desired_count       = 1

  launch_type = "EC2"

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [aws_security_group.instance.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ui.arn
    container_name   = "jaeger"
    container_port   = local.jaeger_ports.ui
  }

}

