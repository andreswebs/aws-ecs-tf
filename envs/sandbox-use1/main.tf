data "aws_region" "current" {}

locals {
  region = data.aws_region.current.name
}

locals {
  task_role_name      = "ecs-${var.cluster_name}-task"
  execution_role_name = "ecs-${var.cluster_name}-execution"
  app_port            = 8080
}

module "ecs_iam" {
  source              = "andreswebs/ecs-iam/aws"
  version             = "0.0.6"
  task_role_name      = local.task_role_name
  execution_role_name = local.execution_role_name
}

module "ecs_cluster" {
  source            = "../../modules/ecs-fargate-cluster"
  name              = var.cluster_name
  vpc_id            = var.vpc_id
  public_subnet_ids = var.public_subnet_ids
}

resource "aws_lb_target_group" "this" {
  # count       = 2
  name        = var.cluster_name
  target_type = "ip"
  port        = local.app_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  health_check {
    path                = "/"
    matcher             = "200-399"
    interval            = 10
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = module.ecs_cluster.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "forward"
    # target_group_arn = aws_lb_target_group.this[0].arn
    target_group_arn = aws_lb_target_group.this.arn
  }
}

resource "aws_ecs_task_definition" "this" {
  family                   = var.cluster_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = module.ecs_iam.role.execution.arn
  task_role_arn            = module.ecs_iam.role.task.arn

  container_definitions = jsonencode([
    {
      name      = "app"
      image     = "public.ecr.aws/andreswebs/busybox-httpd:latest"
      essential = true

      portMappings = [
        {
          containerPort = local.app_port
          protocol      = "tcp"
        },
      ]

      linuxParameters = {
        initProcessEnabled = true
      }

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-region        = local.region
          awslogs-group         = module.ecs_cluster.log_group.name
          awslogs-stream-prefix = "web"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "wget --quiet --tries=1 --spider http://localhost:${local.app_port}/ || exit 1"]
        interval    = 5
        timeout     = 3
        startPeriod = 2
        retries     = 2
      }

    }
  ])
}

resource "aws_ecs_service" "app" {
  name            = var.cluster_name
  cluster         = module.ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.this.arn
  launch_type     = "FARGATE"

  desired_count = 1

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.task.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = "app"
    container_port   = local.app_port
  }

}
