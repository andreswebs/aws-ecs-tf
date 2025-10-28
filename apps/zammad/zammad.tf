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

locals {
  zammad_image               = "ghcr.io/zammad/zammad:6.5.2"
  zammad_storage_volume_name = "zammad-storage"
  zammad_storage_volume_path = "/opt/zammad/storage"

  ## See:
  ## https://github.com/zammad/zammad/blob/develop/bin/docker-entrypoint

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
      name  = "POSTGRESQL_HOST"
      value = local.db_secret.host
    },
    {
      name  = "POSTGRESQL_USER"
      value = local.db_secret.username
    },
    {
      name  = "POSTGRESQL_PASS"
      value = local.db_secret.password
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
