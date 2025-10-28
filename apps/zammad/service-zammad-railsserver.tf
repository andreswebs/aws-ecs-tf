locals {
  zammad_railsserver_container_name = "zammad-railsserver"
  zammad_railsserver_port           = 3000

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
}

resource "aws_service_discovery_service" "zammad_railsserver" {
  name         = local.zammad_railsserver_container_name
  namespace_id = aws_service_discovery_private_dns_namespace.this.id

  dns_config {
    namespace_id   = aws_service_discovery_private_dns_namespace.this.id
    routing_policy = "MULTIVALUE"

    dns_records {
      type = "A"
      ttl  = 10
    }
  }

  tags = var.tags
}

resource "aws_ecs_task_definition" "zammad_railsserver" {
  family                   = local.zammad_railsserver_container_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = module.ecs_iam_zammad.role.execution.arn
  task_role_arn            = module.ecs_iam_zammad.role.task.arn
  container_definitions    = jsonencode([local.zammad_railsserver_container])

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

resource "aws_ecs_service" "zammad_railsserver" {
  name            = local.zammad_railsserver_container_name
  cluster         = module.ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.zammad_railsserver.arn

  enable_ecs_managed_tags = true
  enable_execute_command  = true

  scheduling_strategy = "REPLICA"
  desired_count       = 1

  launch_type = "FARGATE"

  wait_for_steady_state = true

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [aws_security_group.backend.id]
  }

  service_registries {
    registry_arn = aws_service_discovery_service.zammad_railsserver.arn
  }

  tags = var.tags
}
