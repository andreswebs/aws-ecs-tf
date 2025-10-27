locals {
  zammad_railsserver_container_name = "zammad-railsserver"
  zammad_nginx_container_name       = "zammad-nginx"
  zammad_nginx_port                 = 8080

  zammad_railsserver_container = {
    name        = local.zammad_railsserver_container_name
    image       = local.zammad_image
    environment = local.zammad_env
    mountPoints = local.zammad_volume_mounts
    healthCheck = local.zammad_healthcheck
    command     = ["zammad-railsserver"]

    essential         = true
    memoryReservation = 512

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-region        = local.region
        awslogs-group         = local.log_group_name
        awslogs-stream-prefix = local.zammad_railsserver_container_name
      }
    }
  }

  zammad_nginx_container = {
    name        = local.zammad_nginx_container_name
    image       = local.zammad_image
    healthCheck = local.zammad_healthcheck
    command     = ["zammad-nginx"]

    essential         = true
    memoryReservation = 512

    dependsOn = [
      {
        name      = local.zammad_railsserver_container_name
        condition = "HEALTHY"
      },
    ]

    portMappings = [
      {
        name          = "http"
        protocol      = "tcp"
        containerPort = local.zammad_nginx_port
      }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-region        = local.region
        awslogs-group         = local.log_group_name
        awslogs-stream-prefix = local.zammad_nginx_container_name
      }
    }
  }
}
