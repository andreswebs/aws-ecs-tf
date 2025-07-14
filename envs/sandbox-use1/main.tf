locals {
  task_role_name      = "ecs-${var.cluster_name}-task"
  execution_role_name = "ecs-${var.cluster_name}-execution"
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
