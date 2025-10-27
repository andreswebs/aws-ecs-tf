locals {
  zammad_websocket_container_name = "zammad-websocket"

  zammad_websocket_container = {
    name        = local.zammad_websocket_container_name
    image       = local.zammad_image
    environment = local.zammad_env
    mountPoints = local.zammad_volume_mounts
    healthCheck = local.zammad_healthcheck
    command     = ["zammad-websocket"]

    essential         = true
    memoryReservation = 512

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-region        = local.region
        awslogs-group         = local.log_group_name
        awslogs-stream-prefix = local.zammad_websocket_container_name
      }
    }
  }
}
