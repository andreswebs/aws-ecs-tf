module "ecs_iam" {
  source                = "andreswebs/ecs-iam/aws"
  version               = "0.0.1"
  task_role_name        = var.task_role_name
  execution_role_name   = var.execution_role_name
  instance_role_name    = var.instance_role_name
  instance_profile_name = var.instance_profile_name
}

resource "aws_security_group" "efs_access" {
  vpc_id = var.vpc_id
  name   = "${var.cluster_name}-efs-access"

  revoke_rules_on_delete = true

  tags = {
    Name = "${var.cluster_name}-efs-access"
  }
}

resource "aws_vpc_security_group_egress_rule" "this" {
  for_each = toset(local.private_subnet_cidrs_ipv4)

  security_group_id = aws_security_group.efs_access.id

  ip_protocol = "tcp"
  from_port   = 2049
  to_port     = 2049
  cidr_ipv4   = each.value
}

module "efs" {
  source                     = "andreswebs/efs/aws"
  version                    = "0.0.2"
  name                       = var.cluster_name
  subnet_ids                 = var.private_subnet_ids
  allowed_security_group_ids = [aws_security_group.efs_access.id]
  allowed_principal_arns     = [module.ecs_iam.role.execution.arn]
}
