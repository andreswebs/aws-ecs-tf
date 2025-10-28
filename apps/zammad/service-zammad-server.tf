locals {
  zammad_websocket_container_name   = "zammad-websocket"
  zammad_railsserver_container_name = "zammad-railsserver"
  zammad_nginx_container_name       = "zammad-nginx"
  zammad_nginx_port                 = 8080

  zammad_websocket_container = {
    name        = local.zammad_websocket_container_name
    image       = local.zammad_image
    environment = local.zammad_env
    mountPoints = local.zammad_volume_mounts
    healthCheck = local.zammad_healthcheck
    command     = ["zammad-websocket"]

    essential         = true
    memoryReservation = 512

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-region        = local.region
        awslogs-group         = local.log_group_name
        awslogs-stream-prefix = local.zammad_websocket_container_name
      }
    }
  }

  zammad_railsserver_container = {
    name        = local.zammad_railsserver_container_name
    image       = local.zammad_image
    environment = local.zammad_env
    mountPoints = local.zammad_volume_mounts
    healthCheck = local.zammad_healthcheck
    command     = ["zammad-railsserver"]

    essential         = true
    memoryReservation = 512

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-region        = local.region
        awslogs-group         = local.log_group_name
        awslogs-stream-prefix = local.zammad_railsserver_container_name
      }
    }
  }

  zammad_nginx_container = {
    name        = local.zammad_nginx_container_name
    image       = local.zammad_image
    healthCheck = local.zammad_healthcheck
    command     = ["zammad-nginx"]

    essential         = true
    memoryReservation = 256

    dependsOn = [
      {
        containerName = local.zammad_railsserver_container_name
        condition     = "HEALTHY"
      },
    ]

    portMappings = [
      {
        name          = "http"
        protocol      = "tcp"
        containerPort = local.zammad_nginx_port
      }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-region        = local.region
        awslogs-group         = local.log_group_name
        awslogs-stream-prefix = local.zammad_nginx_container_name
      }
    }
  }
}

resource "aws_ecs_task_definition" "zammad_server" {
  family                   = "zammad-server"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = module.ecs_iam_zammad.role.execution.arn
  task_role_arn            = module.ecs_iam_zammad.role.task.arn
  container_definitions = jsonencode([
    local.zammad_websocket_container,
    local.zammad_railsserver_container,
    local.zammad_nginx_container,
  ])

  cpu    = 1024
  memory = 2048

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
}

resource "aws_ecs_service" "zammad_server" {
  name            = "zammad-server"
  cluster         = module.ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.zammad_server.arn

  enable_ecs_managed_tags = true
  enable_execute_command  = true

  scheduling_strategy = "REPLICA"
  desired_count       = 1

  launch_type = "FARGATE"

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [aws_security_group.backend.id]
  }

  tags = var.tags
}
