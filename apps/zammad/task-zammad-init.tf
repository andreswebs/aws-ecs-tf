
locals {
  zammad_init_container_name = "zammad-init"

  zammad_init_container = {
    name        = local.zammad_init_container_name
    image       = local.zammad_image
    environment = local.zammad_env
    mountPoints = local.zammad_volume_mounts
    healthCheck = local.zammad_healthcheck
    command     = ["zammad-init"]

    memoryReservation = 512
    essential         = true

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-region        = local.region
        awslogs-group         = local.log_group_name
        awslogs-stream-prefix = local.zammad_init_container_name
      }
    }
  }
}

resource "aws_ecs_task_definition" "zammad_init" {
  family                   = local.zammad_init_container_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = module.ecs_iam_zammad.role.execution.arn
  task_role_arn            = module.ecs_iam_zammad.role.task.arn
  container_definitions    = jsonencode([local.zammad_init_container])

  cpu    = 2048
  memory = 4096

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = var.task_architecture
  }

  volume {
    name = local.zammad_storage_volume_name

    efs_volume_configuration {
      file_system_id     = module.efs.file_system.id
      root_directory     = "/"
      transit_encryption = "ENABLED"
      authorization_config {
        iam = "ENABLED"
      }
    }
  }

  tags = var.tags

  depends_on = [
    aws_ecs_service.elasticsearch,
    aws_ecs_service.redis,
    aws_elasticache_serverless_cache.this,
  ]
}

data "aws_ecs_task_execution" "zammad_init" {
  cluster         = module.ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.zammad_init.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  enable_ecs_managed_tags = true

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [aws_security_group.backend.id]
  }
}
