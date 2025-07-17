locals {
  web_app_container_defintion = {
    name      = "app"
    image     = "public.ecr.aws/andreswebs/busybox-httpd:latest"
    essential = true

    portMappings = [
      {
        containerPort = local.app_port
        protocol      = "tcp"
      },
    ]

    linuxParameters = {
      initProcessEnabled = true
    }

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-region        = local.region
        awslogs-group         = module.ecs_cluster.log_group.name
        awslogs-stream-prefix = "web"
      }
    }

    healthCheck = {
      command     = ["CMD-SHELL", "wget --quiet --tries=1 --spider http://localhost:${local.app_port}/ || exit 1"]
      interval    = 5
      timeout     = 3
      startPeriod = 2
      retries     = 2
    }

  }
}
