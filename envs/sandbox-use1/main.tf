locals {
  rds_monitoring_role_name = "rds-monitoring"
}

data "aws_iam_role" "rds_monitoring" {
  name = local.rds_monitoring_role_name
}

module "zammad" {
  source                  = "../../apps/zammad"
  name                    = var.zammad_app_name
  private_subnet_ids      = var.private_subnet_ids
  rds_monitoring_role_arn = data.aws_iam_role.rds_monitoring.arn
  dbinit_lambda_image_uri = var.dbinit_lambda_image_uri
}
