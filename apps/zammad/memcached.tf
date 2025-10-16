locals {
  memcached_port = 11211
}

resource "aws_security_group" "memcached" {
  name        = "${var.name}-memcached"
  description = "${var.name} Memcached"
  vpc_id      = local.vpc_id

  revoke_rules_on_delete = true

  tags = merge(var.tags, {
    Name = "${var.name}-memcached"
  })
}

resource "aws_vpc_security_group_ingress_rule" "allow_backend_to_memcached" {
  security_group_id            = aws_security_group.memcached.id
  ip_protocol                  = "tcp"
  from_port                    = local.memcached_port
  to_port                      = local.memcached_port
  referenced_security_group_id = aws_security_group.backend.id

  description = "Allow backend"

  tags = merge(var.tags, {
    Name = "${var.name}-backend-to-memcached"
  })
}

resource "aws_elasticache_serverless_cache" "this" {
  name               = var.name
  engine             = "memcached"
  description        = var.cache_description
  tags               = var.tags
  kms_key_id         = var.kms_key_id
  security_group_ids = [aws_security_group.memcached.id]
  subnet_ids         = var.private_subnet_ids

  major_engine_version = var.memcached_major_version

  cache_usage_limits {
    data_storage {
      maximum = var.cache_storage_gb_max
      unit    = "GB"
    }
    ecpu_per_second {
      maximum = var.cache_ecpu_per_second_max
    }
  }
}

resource "aws_ssm_parameter" "memcached_endpoint" {
  name        = "${local.app_ssm_parameters_prefix}/memchached/endpoint"
  type        = "String"
  value       = local.cache_endpoint
  description = "Memcached endpoint"
  overwrite   = true
  tags        = var.tags
}
