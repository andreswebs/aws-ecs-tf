module "ecs_iam_zammad" {
  source              = "andreswebs/ecs-iam/aws"
  version             = "0.1.0"
  task_role_name      = "${var.name}-task-zammad"
  execution_role_name = "${var.name}-execution-zammad"
  tags                = var.tags
}

resource "aws_iam_role_policy" "zammad_efs" {
  name   = "efs-access"
  policy = module.efs.client_policy_document.json
  role   = module.ecs_iam_zammad.role.task.id
}
