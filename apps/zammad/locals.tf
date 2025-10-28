locals {

  region = data.aws_region.current.region

  vpc_id = data.aws_subnet.selected.vpc_id

  log_group_name = module.ecs_cluster.log_group.name

  cache_endpoint = "${aws_elasticache_serverless_cache.this.endpoint[0].address}:${aws_elasticache_serverless_cache.this.endpoint[0].port}"

  ssm_parameters_prefix_norm = replace(replace("/${trimspace(var.ssm_parameters_prefix)}/", "/^\\/+/", "/"), "/\\/+$/", "/")
  app_ssm_parameters_prefix  = "${local.ssm_parameters_prefix_norm}${var.name}"

  secrets_manager_prefix_norm = replace(replace("/${trimspace(var.secrets_manager_prefix)}/", "/^\\/+/", "/"), "/\\/+$/", "/")
  app_secrets_manager_prefix  = "${local.secrets_manager_prefix_norm}${var.name}"

  db_secret_name_norm = var.db_secret_name == "" ? "db" : "${trimprefix(trimsuffix(trimspace(var.db_secret_name), "/"), "/")}"
  db_secret_name      = "${local.app_secrets_manager_prefix}/${local.db_secret_name_norm}"

  service_discovery_namespace_name = "${var.name}.local"

  redis_endpoint = "${local.redis_container_name}.${local.service_discovery_namespace_name}:${local.redis_port}"

  elasticsearch_architecture_norm  = lower(var.elasticsearch_task_architecture)
  elasticsearch_architecture_infix = local.elasticsearch_architecture_norm == "arm64" ? "arm64/" : ""
  elasticsearch_ami_ssm_parameter  = "/aws/service/ecs/optimized-ami/amazon-linux-2023/${local.elasticsearch_architecture_infix}recommended/image_id"

  elasticsearch_user_data = base64encode(templatefile("${path.module}/tpl/elasticsearch.userdata.tftpl", {
    cluster_name       = var.name
    elasticsearch_home = local.elasticsearch_home
  }))

  elasticsearch_host = "${local.elasticsearch_container_name}.${local.service_discovery_namespace_name}"

  ecs_cluster_capacity_providers = ["FARGATE", aws_ecs_capacity_provider.elasticsearch.name]

  db_username           = "zammad"
  db_password           = random_password.db.result
  db_master_secret_arn  = try(module.db.db_instance.master_user_secret[0].secret_arn, "")
  db_master_secret_name = replace(trimprefix(try(provider::aws::arn_parse(local.db_master_secret_arn).resource, ""), "secret:"), "/-.{6}$/", "")

  db_secret = {
    engine               = module.db.db_instance.engine
    host                 = module.db.db_instance.address
    port                 = module.db.db_instance.port
    dbname               = module.db.db_instance.db_name
    dbInstanceIdentifier = module.db.db_instance.identifier
    masterarn            = local.db_master_secret_arn
    username             = local.db_username
    password             = local.db_password
  }

  dbinit_env = {
    DB_MIGRATION_SECRET = aws_secretsmanager_secret.db.arn
    DB_MIGRATION_ROLE   = "zammad_app"
    DB_SCHEMA           = "zammad_data"
  }

  zammad_websocket_host   = "${local.zammad_websocket_container_name}.${local.service_discovery_namespace_name}"
  zammad_railsserver_host = "${local.zammad_railsserver_container_name}.${local.service_discovery_namespace_name}"
}
