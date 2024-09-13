locals {
  wg_dummy_healthcheck = {
    name              = "healthcheck",
    image             = "busybox:latest",
    essential         = true,
    memoryReservation = 64
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

    healthCheck = {
      command = ["CMD-SHELL", "which ip  || exit 1"]
    }
  }
}
