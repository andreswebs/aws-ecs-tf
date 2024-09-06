locals {
  wg_conf_name     = "wg-conf"
  lib_modules_name = "lib-modules"

  container_definitions = jsonencode([
    {
      name              = "wireguard"
      image             = var.wg_image
      memoryReservation = 256
      essential         = true

      user = "${var.app_uid}:${var.app_gid}"

      linuxParameters = {
        initProcessEnabled = true
        capabilities = {
          add = [
            "NET_ADMIN",
            "SYS_MODULE",
          ]
        }
      }

      systemControls = [
        {
          namespace = "net.ipv4.conf.all.src_valid_mark"
          value     = "1"
        },
        {
          namespace = "net.ipv4.ip_forward"
          value     = "1"
        },
        {
          namespace = "net.ipv4.conf.all.proxy_arp"
          value     = "1"
        },
      ]

      environment = [
        {
          name  = "PUID"
          value = tostring(var.app_uid)
        },
        {
          name  = "PGID"
          value = tostring(var.app_gid)
        },
        {
          name  = "TZ"
          value = "Etc/UTC"
        },
        {
          name  = "LOG_CONFS"
          value = "true"
        },
        {
          name  = "INTERNAL_SUBNET"
          value = "10.13.13.0" # only change if it clashes
        },
        {
          name  = "SERVERPORT"
          value = tostring(var.container_port)
        },
        {
          name  = "SERVERURL" # =wireguard.example.com
          value = var.wg_serverurl
        },
        {
          name  = "PEERS"
          value = var.wg_peers
        },
        {
          name  = "ALLOWEDIPS" # split tunneling: set this to only the IPs that will use the tunnel AND the WG server's ip, such as 10.13.13.1.
          value = var.wg_allowedips
        },
      ]

      portMappings = [
        {
          name          = "udp"
          protocol      = "udp"
          containerPort = var.container_port
          hostPort      = var.container_port
        },
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = local.log_group_name
          awslogs-region        = local.region
          awslogs-stream-prefix = "wireguard"
        }
      }

      mountPoints = [
        {
          sourceVolume  = local.wg_conf_name
          containerPath = "/config"
        },
        {
          sourceVolume  = local.lib_modules_name
          containerPath = "/lib/modules"
        }
      ]
    },
    {
      name              = "healthcheck",
      image             = "busybox:latest",
      essential         = true,
      memoryReservation = 32
      portMappings = [
        {
          name          = "healthcheck"
          protocol      = "tcp"
          containerPort = var.health_check_port,
          hostPort      = var.health_check_port,
        }
      ],
      entryPoint = [
        "sh",
        "-c"
      ],
      command = [
        "while true; do { echo -e 'HTTP/1.1 200 OK\r\n'; echo 'ok'; } | nc -l -p ${var.health_check_port}; done"
      ]
    }
  ])

}
