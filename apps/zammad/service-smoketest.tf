locals {

  smoketest_image          = "bash:5.3.3-alpine3.22"
  smoketest_container_name = "smoketest"

  smoketest_container = {
    name              = local.smoketest_container_name
    image             = local.smoketest_image
    memoryReservation = 256
    essential         = true

    linuxParameters = {
      initProcessEnabled = true
    }

    command = ["sleep", "infinity"]

    environment = [
      {
        name  = "TEST"
        value = "ok"
      },
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-region        = local.region
        awslogs-group         = local.log_group_name
        awslogs-stream-prefix = local.smoketest_container_name
      }
    }

    healthCheck = {
      command = ["CMD-SHELL", "echo ok || exit 1"]
    }

  }
}

module "ecs_iam_smoketest" {
  source              = "andreswebs/ecs-iam/aws"
  version             = "0.0.8"
  task_role_name      = "${var.name}-task-smoketest"
  execution_role_name = "${var.name}-execution-smoketest"
  tags                = var.tags
}

resource "aws_ecs_task_definition" "smoketest" {
  family                   = local.smoketest_container_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = module.ecs_iam_smoketest.role.execution.arn
  task_role_arn            = module.ecs_iam_smoketest.role.task.arn
  container_definitions    = jsonencode([local.smoketest_container])

  cpu    = 256
  memory = 512

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = var.task_architecture
  }

  tags = var.tags
}

resource "aws_ecs_service" "smoketest" {
  name            = local.smoketest_container_name
  cluster         = module.ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.smoketest.arn

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
