
resource "aws_security_group" "cache" {
  name        = local.cache_security_group_name
  description = var.cache_security_group_description
  vpc_id      = local.vpc_id

  revoke_rules_on_delete = true

  tags = merge(var.tags, {
    Name = local.cache_security_group_name
  })
}

## TODO: ingress rule for memcached
# resource "aws_vpc_security_group_ingress_rule" "allow_memcached" {
#   security_group_id = aws_security_group.this.id
#   ip_protocol       = "tcp"
#   from_port         = 11211
#   to_port           = 11211
#   cidr_ipv4         = "" ## TODO <-- use the task SG instead

#   description = "Allow HTTP"

#   tags = merge(var.tags, {
#     Name = format("%s-http", local.sg_name)
#   })
# }

resource "aws_elasticache_serverless_cache" "this" {
  name               = var.name
  engine             = "memcached"
  description        = var.cache_description
  tags               = var.tags
  kms_key_id         = var.kms_key_id
  security_group_ids = [aws_security_group.cache.id]
  subnet_ids         = var.private_subnet_ids

  major_engine_version = "1.6"

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
  description = "Zammad memcached endpoint"
  overwrite   = true
  tags        = var.tags
}
