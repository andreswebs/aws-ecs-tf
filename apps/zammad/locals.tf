locals {

  region = data.aws_region.current.region

  vpc_id = data.aws_subnet.selected.vpc_id

  log_group_name = module.ecs_cluster.log_group.name

  cache_endpoint = "${aws_elasticache_serverless_cache.this.endpoint[0].address}:${aws_elasticache_serverless_cache.this.endpoint[0].port}"

  ssm_parameters_prefix_norm = var.ssm_parameters_prefix == "" ? var.ssm_parameters_prefix : "/${trimprefix(trimsuffix(trimspace(var.ssm_parameters_prefix), "/"), "/")}"
  app_ssm_parameters_prefix  = "${local.ssm_parameters_prefix_norm}/${var.name}"

  service_discovery_namespace_name = "${var.name}.local"

  redis_endpoint = "${local.redis_container_name}.${local.service_discovery_namespace_name}:${local.redis_port}"

}
