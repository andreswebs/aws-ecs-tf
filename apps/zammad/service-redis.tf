locals {

  redis_image          = "redis:7.4.5-alpine"
  redis_container_name = "redis"
  redis_port           = 6379

  redis_container = {
    name              = local.redis_container_name
    image             = local.redis_image
    memoryReservation = 512
    essential         = true

    linuxParameters = {
      initProcessEnabled = true
    }

    command = [
      "redis-server",
      "--appendonly",
      "no",
      "--maxmemory",
      var.redis_max_memory,
      "--maxmemory-policy",
      "allkeys-lru"
    ]

    portMappings = [
      {
        name          = "redis"
        protocol      = "tcp"
        containerPort = local.redis_port
        hostPort      = local.redis_port
      },
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-region        = local.region
        awslogs-group         = local.log_group_name
        awslogs-stream-prefix = local.redis_container_name
      }
    }

    healthCheck = {
      command = ["CMD", "redis-cli", "ping"]
    }

  }
}

module "ecs_iam_redis" {
  source              = "andreswebs/ecs-iam/aws"
  version             = "0.1.0"
  task_role_name      = "${var.name}-task-${local.redis_container_name}"
  execution_role_name = "${var.name}-execution-${local.redis_container_name}"
  tags                = var.tags
}

resource "aws_security_group" "redis" {
  name        = "${var.name}-redis"
  description = "${var.name} Redis"
  vpc_id      = local.vpc_id

  revoke_rules_on_delete = true

  tags = merge(var.tags, {
    Name = "${var.name}-redis"
  })
}

resource "aws_vpc_security_group_ingress_rule" "allow_backend_to_redis" {
  security_group_id            = aws_security_group.redis.id
  ip_protocol                  = "tcp"
  from_port                    = local.redis_port
  to_port                      = local.redis_port
  referenced_security_group_id = aws_security_group.backend.id

  description = "Allow backend"

  tags = merge(var.tags, {
    Name = "${var.name}-backend-to-${local.redis_container_name}"
  })
}

resource "aws_vpc_security_group_egress_rule" "redis_https" {
  security_group_id = aws_security_group.redis.id
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"

  description = "Allow HTTPS"

  tags = merge(var.tags, {
    Name = "${var.name}-${local.redis_container_name}-https"
  })
}

resource "aws_service_discovery_service" "redis" {
  name         = local.redis_container_name
  namespace_id = aws_service_discovery_private_dns_namespace.this.id

  dns_config {
    namespace_id   = aws_service_discovery_private_dns_namespace.this.id
    routing_policy = "MULTIVALUE"

    dns_records {
      type = "A"
      ttl  = 10
    }
  }

  tags = var.tags
}

resource "aws_ecs_task_definition" "redis" {
  family                   = local.redis_container_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = module.ecs_iam_redis.role.execution.arn
  task_role_arn            = module.ecs_iam_redis.role.task.arn
  container_definitions    = jsonencode([local.redis_container])

  cpu    = 512
  memory = 1024

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = var.task_architecture
  }

  ephemeral_storage {
    size_in_gib = 30
  }

  tags = var.tags
}

resource "aws_ecs_service" "redis" {
  name            = local.redis_container_name
  cluster         = module.ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.redis.arn

  enable_ecs_managed_tags = true
  enable_execute_command  = true

  scheduling_strategy = "REPLICA"
  desired_count       = 1

  launch_type = "FARGATE"

  wait_for_steady_state = true

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [aws_security_group.redis.id]
  }

  service_registries {
    registry_arn = aws_service_discovery_service.redis.arn
  }

  tags = var.tags
}

resource "aws_ssm_parameter" "redis_endpoint" {
  name        = "${local.app_ssm_parameters_prefix}/redis/endpoint"
  type        = "String"
  value       = local.redis_endpoint
  description = "Redis endpoint"
  overwrite   = true
  tags        = var.tags
}
