locals {
  rds_monitoring_role_name = "rds-monitoring"
  zammad_app_domain_name   = "${var.zammad_app_name}.${var.domain_name}"
}

data "aws_iam_role" "rds_monitoring" {
  name = local.rds_monitoring_role_name
}

data "aws_route53_zone" "this" {
  name         = "${var.domain_name}."
  private_zone = false
}

# data "aws_acm_certificate" "this" {
#   domain      = var.domain_name
#   types       = ["AMAZON_ISSUED"]
#   most_recent = true
# }

module "alb" {
  source               = "../../modules/web-alb"
  name                 = var.zammad_app_name
  public_subnet_ids    = var.public_subnet_ids
  acm_certificate_arns = [var.acm_certificate_arn]
}

module "zammad" {
  source                  = "../../apps/zammad"
  name                    = var.zammad_app_name
  private_subnet_ids      = var.private_subnet_ids
  rds_monitoring_role_arn = data.aws_iam_role.rds_monitoring.arn
  dbinit_lambda_image_uri = var.dbinit_lambda_image_uri
  app_domain_name         = local.zammad_app_domain_name
  lb_listener_arn         = module.alb.listener.https.arn
  lb_lister_rule_priority = 100
  lb_security_group_id    = module.alb.sg.id
}

resource "aws_route53_record" "zammad" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = local.zammad_app_domain_name
  type    = "A"

  alias {
    name                   = module.alb.lb.dns_name
    zone_id                = module.alb.lb.zone_id
    evaluate_target_health = true
  }
}
