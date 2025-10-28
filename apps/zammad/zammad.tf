module "ecs_iam_zammad" {
  source              = "andreswebs/ecs-iam/aws"
  version             = "0.1.0"
  task_role_name      = "${var.name}-task-zammad"
  execution_role_name = "${var.name}-execution-zammad"
  tags                = var.tags
}

module "iam_policy_document_zammad_secret_access" {
  source  = "andreswebs/secrets-access-policy-document/aws"
  version = "1.8.0"
  secret_names = compact([
    aws_secretsmanager_secret.db.name,
  ])
}

resource "aws_iam_role_policy" "zammad_secrets" {
  policy = module.iam_policy_document_zammad_secret_access.json
  role   = module.ecs_iam_zammad.role.execution.id
}

resource "aws_iam_role_policy" "zammad_efs" {
  name   = "efs-access"
  policy = module.efs.client_policy_document.json
  role   = module.ecs_iam_zammad.role.task.id
}

locals {
  zammad_image               = "ghcr.io/zammad/zammad:6.5.2"
  zammad_storage_volume_name = "zammad-storage"
  zammad_storage_volume_path = "/opt/zammad/storage"

  ## See:
  ## https://github.com/zammad/zammad/blob/develop/bin/docker-entrypoint
  ## https://docs.zammad.org/en/latest/appendix/configure-env-vars.html

  zammad_env = [
    {
      name  = "REDIS_URL"
      value = "redis://${local.redis_endpoint}"
    },
    {
      name  = "MEMCACHE_SERVERS"
      value = local.cache_endpoint
    },
    {
      name  = "ELASTICSEARCH_ENABLED"
      value = "true"
    },
    {
      name  = "ELASTICSEARCH_SSL_VERIFY"
      value = "false"
    },
    {
      name  = "ELASTICSEARCH_SCHEMA"
      value = "http"
    },
    {
      name  = "ELASTICSEARCH_HOST"
      value = local.elasticsearch_host
    },
    {
      name  = "ELASTICSEARCH_PORT"
      value = tostring(local.elasticsearch_port)
    },
    {
      name  = "ELASTICSEARCH_NAMESPACE"
      value = "zammad"
    },
    {
      name  = "NGINX_SERVER_SCHEME"
      value = "https"
    },
    {
      name  = "NGINX_PORT"
      value = tostring(local.zammad_nginx_port)
    },
    {
      name  = "POSTGRESQL_HOST"
      value = local.db_secret.host
    },
    {
      name  = "POSTGRESQL_USER"
      value = local.db_secret.username
    },
    {
      name  = "POSTGRESQL_DB"
      value = "zammad"
    },
    {
      name  = "POSTGRESQL_DB_CREATE"
      value = "false"
    },
    {
      name  = "POSTGRESQL_OPTIONS"
      value = "?pool=50&sslmode=require&channel_binding=require"
    },
    {
      name  = "ZAMMAD_FQDN"
      value = var.zammad_fqdn
    },
    {
      name  = "ZAMMAD_WEBSOCKET_HOST"
      value = local.zammad_websocket_host
    },
    {
      name  = "ZAMMAD_WEBSOCKET_PORT"
      value = tostring(local.zammad_websocket_port)
    },
    {
      name  = "ZAMMAD_RAILSSERVER_HOST"
      value = local.zammad_railsserver_host
    },
    {
      name  = "ZAMMAD_RAILSSERVER_PORT"
      value = tostring(local.zammad_railsserver_port)
    },
  ]

  zammad_secrets = [
    {
      name      = "POSTGRESQL_PASS"
      valueFrom = "${aws_secretsmanager_secret.db.arn}:password::"
    },
  ]

  zammad_volume_mounts = [
    {
      sourceVolume  = local.zammad_storage_volume_name
      containerPath = local.zammad_storage_volume_path
      readOnly      = false
    },
  ]

  zammad_healthcheck = {
    command = ["CMD-SHELL", "echo ok || exit 1"]
  }
}
