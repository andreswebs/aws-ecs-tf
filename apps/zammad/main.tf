module "ecs_cluster" {
  source                = "../../modules/ecs-cluster"
  name                  = var.name
  log_group_name_prefix = var.log_group_name_prefix
  log_retention_in_days = var.log_retention_in_days
  tags                  = var.tags
}
