variable "name" {
  type        = string
  description = "App name; used to construct names for internal resources"
}

variable "log_group_name_prefix" {
  description = "Log group name prefix"
  type        = string
  default     = "/aws/ecs/"

  validation {
    condition     = var.log_group_name_prefix == "" || can(regex("^/.*/$", var.log_group_name_prefix))
    error_message = "`log_group_name_prefix` must be either an empty string or start and end with a slash ('/')."
  }
}

variable "log_retention_in_days" {
  description = "Log retention days"
  type        = number
  default     = 30
}

variable "tags" {
  description = "(Optional) Map of tags to apply to created resources"
  type        = map(string)
  default     = {}
}

variable "cache_description" {
  type        = string
  description = "Description for the `aws_elasticache_serverless_cache` (memcached)"
  default     = "Zammad Memcached serverless"
}

variable "cache_storage_gb_max" {
  type        = number
  description = "Maximum storage in GB for the cache"
  default     = 10
}

variable "cache_ecpu_per_second_max" {
  type        = number
  description = "Maximum ElastiCache Processing Units (ECPUs) the cache can consume per second"
  default     = 5000

  validation {
    condition     = var.cache_ecpu_per_second_max >= 1000 && var.cache_ecpu_per_second_max <= 15000000
    error_message = "`cache_ecpu_per_second_max` must be between 1,000 and 15,000,000."
  }
}

variable "kms_key_id" {
  type        = string
  description = "KMS key ID"
  default     = null
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs"

  validation {
    condition     = length(var.private_subnet_ids) >= 3
    error_message = "You must specify at least 3 private subnet IDs."
  }
}

variable "ssm_parameters_prefix" {
  type        = string
  description = "Default prefix for generated SSM parameters"
  default     = ""

  validation {
    condition     = var.ssm_parameters_prefix != null
    error_message = "`ssm_parameters_prefix` must not be null."
  }
}

variable "secrets_manager_prefix" {
  type        = string
  description = "Default prefix for generated secrets"
  default     = ""

  validation {
    condition     = var.secrets_manager_prefix != null
    error_message = "`secrets_manager_prefix` must not be null."
  }
}

variable "task_architecture" {
  description = "CPU architecture used for ECS tasks"
  type        = string
  default     = "X86_64"

  validation {
    condition     = contains(["X86_64", "ARM64"], var.task_architecture)
    error_message = "`task_architecture` can be either `X86_64` or `ARM64`"
  }
}

variable "memcached_major_version" {
  type        = string
  description = "ElastiCache Memcached major engine version"
  default     = "1.6"

  validation {
    condition     = can(regex("^\\d+\\.\\d+$", var.memcached_major_version))
    error_message = "`memcached_major_version` must be in the format x.x (e.g., 1.6, 1.5)"
  }
}

variable "redis_max_memory" {
  type        = string
  description = "Value passed to the redis-server --maxmemory flag"
  default     = "500mb"
}

variable "rds_monitoring_role_arn" {
  type        = string
  description = "RDS monitoring role ARN"
  default     = null
}

variable "dbinit_lambda_image_uri" {
  type    = string
  default = null
}

variable "dbinit_enabled" {
  type    = bool
  default = true
}

variable "db_secret_name" {
  type    = string
  default = "db"

  validation {
    condition     = var.db_secret_name != null
    error_message = "`db_secret_name` must not be null."
  }
}

variable "db_secret_recovery_window_in_days" {
  type    = number
  default = 0
}

variable "db_skip_final_snapshot" {
  type    = bool
  default = true
}

variable "postgres_major_version" {
  type    = string
  default = "17.6"
}

variable "elasticsearch_instance_type" {
  type    = string
  default = "t4g.medium"
}

variable "elasticsearch_task_architecture" {
  type    = string
  default = "ARM64"

  validation {
    condition     = contains(["X86_64", "ARM64"], var.elasticsearch_task_architecture)
    error_message = "`elasticsearch_task_architecture` can be either `X86_64` or `ARM64`"
  }
}

variable "app_domain_name" {
  type = string
}

variable "lb_listener_arn" {
  type = string
}

variable "lb_lister_rule_priority" {
  type = number
}

variable "lb_security_group_id" {
  type = string
}
