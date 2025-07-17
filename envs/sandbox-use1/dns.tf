data "aws_route53_zone" "this" {
  name         = "${var.domain_name}."
  private_zone = false
}

locals {
  app_domain_name = "${var.cluster_name}.${data.aws_route53_zone.this.name}"
}

resource "aws_route53_record" "app" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = local.app_domain_name
  type    = "A"

  alias {
    name                   = module.ecs_cluster.alb.dns_name
    zone_id                = module.ecs_cluster.alb.zone_id
    evaluate_target_health = true
  }
}
