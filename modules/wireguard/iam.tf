module "ecs_iam" {
  source                = "andreswebs/ecs-iam/aws"
  version               = "0.0.1"
  task_role_name        = var.task_role_name
  execution_role_name   = var.execution_role_name
  instance_role_name    = var.instance_role_name
  instance_profile_name = var.instance_profile_name
}

resource "aws_iam_role_policy" "task_efs_access" {
  name   = "efs-access"
  role   = module.ecs_iam.role.task.name
  policy = module.efs.client_policy.json
}
