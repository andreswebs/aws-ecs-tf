module "db_net" {
  source                        = "../../modules/rds-db-net"
  db_subnet_group_name          = var.name
  subnet_ids                    = var.private_subnet_ids
  db_security_group_name        = "${var.name}-db"
  db_security_group_description = "Database security group for ${var.name}"
}

module "db" {
  source                      = "../../modules/rds-postgresql"
  instance_identifier         = var.name
  subnet_group_name           = module.db_net.subnet_group.name
  security_group_ids          = [module.db_net.security_group.id]
  parameter_group_description = "${var.name} DB parameters"
  monitoring_role_arn         = var.rds_monitoring_role_arn
  db_name                     = "zammad"

  engine_version = "17.6"

  kms_key_id                      = var.kms_key_id
  master_user_secret_kms_key_id   = var.kms_key_id
  performance_insights_kms_key_id = var.kms_key_id

  skip_final_snapshot = true
}

resource "aws_vpc_security_group_ingress_rule" "allow_backend_to_db" {
  security_group_id            = module.db_net.security_group.id
  ip_protocol                  = "tcp"
  from_port                    = module.db.db_instance.port
  to_port                      = module.db.db_instance.port
  referenced_security_group_id = aws_security_group.backend.id

  description = "Allow backend"

  tags = merge(var.tags, {
    Name = "${var.name}-backend-to-db"
  })
}

resource "random_password" "db" {
  length      = 32
  special     = false
  min_lower   = 1
  min_numeric = 1
  min_upper   = 1
}

resource "aws_secretsmanager_secret" "db" {
  name                    = local.db_secret_name
  kms_key_id              = var.kms_key_id
  recovery_window_in_days = var.db_secret_recovery_window_in_days
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id     = aws_secretsmanager_secret.db.id
  secret_string = jsonencode(local.db_secret)
}
