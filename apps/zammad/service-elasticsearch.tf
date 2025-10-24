locals {
  elasticsearch_image            = "bash:5.3.3-alpine3.22" ## WIP
  elasticsearch_container_name   = "elasticsearch"
  elasticsearch_port             = 9200
  elasticsearch_data_volume_name = "elasticsearch-data"
  elasticsearch_data_volume_path = "/usr/share/elasticsearch/data"

  elasticsearch_container = {
    name              = local.elasticsearch_container_name
    image             = local.elasticsearch_image
    memoryReservation = 1024
    essential         = true

    linuxParameters = {
      initProcessEnabled = true
    }

    command = ["sleep", "infinity"]

    portMappings = [
      {
        name          = "elasticsearch"
        protocol      = "tcp"
        containerPort = local.elasticsearch_port
        hostPort      = local.elasticsearch_port
      },
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-region        = local.region
        awslogs-group         = local.log_group_name
        awslogs-stream-prefix = local.elasticsearch_container_name
      }
    }

    healthCheck = {
      command = ["CMD-SHELL", "echo ok || exit 1"]
    }

    mountPoints = [
      {
        sourceVolume  = local.elasticsearch_data_volume_name
        containerPath = local.elasticsearch_data_volume_path
        readOnly      = false
      },
    ]

    ulimits = [
      {
        name      = "nofile"
        softLimit = 65536
        hardLimit = 65536
      }
    ],

  }
}

module "ec2_role_elasticsearch" {
  source           = "andreswebs/ec2-role/aws"
  version          = "3.0.0"
  role_name        = "${var.name}-elasticsearch-instance"
  role_description = "EC2 instance role for ${var.name} Elasticsearch ECS nodes"
  profile_name     = "${var.name}-elasticsearch-instance"
  tags             = var.tags

  attach_container_service_policy = true
}

module "ecs_iam_elasticsearch" {
  source              = "andreswebs/ecs-iam/aws"
  version             = "0.1.0"
  task_role_name      = "${var.name}-task-${local.elasticsearch_container_name}"
  execution_role_name = "${var.name}-execution-${local.elasticsearch_container_name}"
  tags                = var.tags
}

resource "aws_security_group" "elasticsearch" {
  name        = "${var.name}-elasticsearch"
  description = "${var.name} Elasticsearch"
  vpc_id      = local.vpc_id

  revoke_rules_on_delete = true

  tags = merge(var.tags, {
    Name = "${var.name}-elasticsearch"
  })
}

resource "aws_vpc_security_group_ingress_rule" "allow_backend_to_elasticsearch" {
  security_group_id            = aws_security_group.elasticsearch.id
  ip_protocol                  = "tcp"
  from_port                    = local.elasticsearch_port
  to_port                      = local.elasticsearch_port
  referenced_security_group_id = aws_security_group.backend.id

  description = "Allow backend"

  tags = merge(var.tags, {
    Name = "${var.name}-backend-to-${local.elasticsearch_container_name}"
  })
}

resource "aws_vpc_security_group_egress_rule" "elasticsearch_https" {
  security_group_id = aws_security_group.elasticsearch.id
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"

  description = "Allow HTTPS"

  tags = merge(var.tags, {
    Name = "${var.name}-${local.elasticsearch_container_name}-https"
  })
}

resource "aws_security_group" "elasticsearch_instance" {
  name        = "${var.name}-elasticsearch-instance"
  description = "${var.name} Elasticsearch EC2 node"
  vpc_id      = local.vpc_id

  revoke_rules_on_delete = true

  tags = merge(var.tags, {
    Name = "${var.name}-elasticsearch-instance"
  })
}

resource "aws_vpc_security_group_egress_rule" "elasticsearch_instance_https" {
  security_group_id = aws_security_group.elasticsearch_instance.id
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"

  description = "Allow HTTPS"

  tags = merge(var.tags, {
    Name = "${var.name}-elasticsearch-instance-https"
  })
}

resource "aws_launch_template" "elasticsearch" {
  name                   = "${var.name}-elasticsearch"
  description            = "Launch template for ECS cluster ${var.name} Elasticsearch nodes"
  update_default_version = true

  instance_type          = var.elasticsearch_instance_type
  image_id               = "resolve:ssm:${local.elasticsearch_ami_ssm_parameter}"
  vpc_security_group_ids = [aws_security_group.elasticsearch_instance.id]
  user_data              = local.elasticsearch_user_data

  monitoring {
    enabled = true
  }

  iam_instance_profile {
    name = module.ec2_role_elasticsearch.instance_profile.name
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_protocol_ipv6          = "enabled"
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "enabled"
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.name}-elasticsearch"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "elasticsearch" {
  name = "${var.name}-elasticsearch"

  vpc_zone_identifier = var.private_subnet_ids

  desired_capacity = 1
  max_size         = 2
  min_size         = 1

  launch_template {
    id      = aws_launch_template.elasticsearch.id
    version = aws_launch_template.elasticsearch.latest_version
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }

  lifecycle {
    ignore_changes = [
      load_balancers,
      target_group_arns,
    ]
  }

}

resource "aws_ecs_capacity_provider" "elasticsearch" {
  name = "${var.name}-elasticsearch"
  tags = var.tags

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.elasticsearch.arn

    managed_scaling {
      status                    = "DISABLED"
      maximum_scaling_step_size = 1000
      minimum_scaling_step_size = 1
      target_capacity           = 100
    }
  }

}

resource "aws_ecs_task_definition" "elasticsearch" {
  family                   = local.elasticsearch_container_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  execution_role_arn       = module.ecs_iam_elasticsearch.role.execution.arn
  task_role_arn            = module.ecs_iam_elasticsearch.role.task.arn
  container_definitions    = jsonencode([local.elasticsearch_container])
  tags                     = var.tags

  volume {
    name      = local.elasticsearch_data_volume_name
    host_path = local.elasticsearch_data_volume_path
  }
}

resource "aws_ecs_service" "elasticsearch" {
  name            = local.elasticsearch_container_name
  cluster         = module.ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.elasticsearch.arn

  enable_ecs_managed_tags = true
  enable_execute_command  = true

  scheduling_strategy = "REPLICA"
  desired_count       = 1

  launch_type = "EC2"

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [aws_security_group.elasticsearch.id]
  }

  placement_constraints {
    type = "distinctInstance"
  }

  tags = var.tags
}
