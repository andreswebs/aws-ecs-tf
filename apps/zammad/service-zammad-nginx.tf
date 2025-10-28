locals {
  zammad_nginx_container_name = "zammad-nginx"
  zammad_nginx_port           = 8080

  zammad_nginx_container = {
    name        = local.zammad_nginx_container_name
    image       = local.zammad_image
    environment = local.zammad_env
    secrets     = local.zammad_secrets
    healthCheck = local.zammad_healthcheck
    command     = ["zammad-nginx"]

    essential         = true
    memoryReservation = 256

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

resource "aws_ecs_task_definition" "zammad_nginx" {
  family                   = local.zammad_nginx_container_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = module.ecs_iam_zammad.role.execution.arn
  task_role_arn            = module.ecs_iam_zammad.role.task.arn
  container_definitions    = jsonencode([local.zammad_nginx_container])

  cpu    = 512
  memory = 1024

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = var.task_architecture
  }

  tags = var.tags
}

resource "aws_ecs_service" "zammad_nginx" {
  name            = local.zammad_nginx_container_name
  cluster         = module.ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.zammad_nginx.arn

  enable_ecs_managed_tags = true
  enable_execute_command  = true

  scheduling_strategy = "REPLICA"
  desired_count       = 1

  launch_type = "FARGATE"

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [aws_security_group.proxy.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = local.zammad_nginx_container_name
    container_port   = local.zammad_nginx_port
  }

  depends_on = [aws_ecs_service.zammad_websocket, aws_ecs_service.zammad_railsserver]

  tags = var.tags
}
