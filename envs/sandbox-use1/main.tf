data "aws_region" "current" {}

locals {
  region = data.aws_region.current.name
}

locals {
  task_role_name       = "ecs-${var.cluster_name}-task"
  execution_role_name  = "ecs-${var.cluster_name}-execution"
  codedeploy_role_name = "ecs-${var.cluster_name}-codedeploy"
  app_port             = 8080
}

module "ecs_iam" {
  source               = "andreswebs/ecs-iam/aws"
  version              = "0.0.7"
  execution_role_name  = local.execution_role_name
  task_role_name       = local.task_role_name
  codedeploy_role_name = local.codedeploy_role_name
}

module "ecs_cluster" {
  source            = "../../modules/ecs-fargate-cluster"
  name              = var.cluster_name
  vpc_id            = var.vpc_id
  public_subnet_ids = var.public_subnet_ids
}

module "ecs_target" {
  source              = "../../modules/ecs-lb-web-target-bluegreen"
  vpc_id              = var.vpc_id
  target_group_name   = var.cluster_name
  target_port         = local.app_port
  load_balancer_arn   = module.ecs_cluster.alb.arn
  acm_certificate_arn = var.acm_certificate_arn

  depends_on = [module.ecs_cluster]
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
    local.web_app_container_defintion,
  ])
}

resource "aws_ecs_service" "this" {
  name            = var.cluster_name
  cluster         = module.ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.this.arn
  launch_type     = "FARGATE"

  scheduling_strategy  = "REPLICA"
  desired_count        = 1
  force_new_deployment = true

  health_check_grace_period_seconds = 30

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.task.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = module.ecs_target.target_group[0].arn
    container_name   = "app"
    container_port   = local.app_port
  }

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  lifecycle {
    ignore_changes = [task_definition, desired_count, load_balancer]
  }

  depends_on = [module.ecs_cluster]
}
