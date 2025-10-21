variable "availability_zone" {
  type        = string
  description = "Database instance availability zone"
  default     = null
}

variable "read_replica_availability_zones" {
  type        = list(string)
  description = "List of read replica  availability zones"
  default     = []
}

variable "parameter_group_description" {
  description = "Database parameter group description"
  type        = string
  default     = null
}

variable "db_default_parameters" {
  description = "List of default database configuration parameter objects for parameter group"

  type = list(object({
    name         = string
    value        = string
    apply_method = optional(string, "pending-reboot")
  }))

  default = [
    {
      name         = "shared_preload_libraries"
      value        = "pg_tle,pg_stat_statements,pgaudit,orafce"
      apply_method = "pending-reboot"
    },
    { name         = "log_destination"
      value        = "stderr"
      apply_method = "pending-reboot"
    },
    { name         = "log_filename"
      value        = "postgresql.log.%Y-%m-%d-%H"
      apply_method = "pending-reboot"
    },
    { name         = "log_rotation_age"
      value        = "1440"
      apply_method = "pending-reboot"
    },
    { name         = "log_rotation_size"
      value        = "10240"
      apply_method = "pending-reboot"
    },
    { name         = "log_min_messages"
      value        = "error"
      apply_method = "pending-reboot"
    },
    { name         = "log_min_error_statement"
      value        = "error"
      apply_method = "pending-reboot"
    },
    { name         = "debug_print_parse"
      value        = "off"
      apply_method = "pending-reboot"
    },
    { name         = "debug_print_rewritten"
      value        = "off"
      apply_method = "pending-reboot"
    },
    { name         = "debug_print_plan"
      value        = "off"
      apply_method = "pending-reboot"
    },
    { name         = "debug_pretty_print"
      value        = "on"
      apply_method = "pending-reboot"
    },
    { name         = "log_connections"
      value        = "on"
      apply_method = "pending-reboot"
    },
    { name         = "log_disconnections"
      value        = "on"
      apply_method = "pending-reboot"
    },
    { name         = "log_error_verbosity"
      value        = "default"
      apply_method = "pending-reboot"
    },
    { name         = "log_hostname"
      value        = "off"
      apply_method = "pending-reboot"
    },
    { name         = "log_line_prefix"
      value        = "%t:%r:%u@%d:[%p]:"
      apply_method = "pending-reboot"
    },
    { name         = "log_statement"
      value        = "none"
      apply_method = "pending-reboot"
    },
    { name         = "pgaudit.log"
      value        = "ddl,write,role,misc,read"
      apply_method = "pending-reboot"
    },
    { name         = "pgaudit.log_catalog"
      value        = "off"
      apply_method = "pending-reboot"
    },
    { name         = "pgaudit.log_level"
      value        = "log"
      apply_method = "pending-reboot"
    },
    { name         = "pgaudit.log_parameter"
      value        = "on"
      apply_method = "pending-reboot"
    },
    { name         = "pgaudit.log_relation"
      value        = "on"
      apply_method = "pending-reboot"
    },
    { name         = "pgaudit.log_statement_once"
      value        = "off"
      apply_method = "pending-reboot"
    },
    { name         = "pgaudit.role"
      value        = "rds_pgaudit"
      apply_method = "pending-reboot"
    },
    { name         = "client_min_messages"
      value        = "error"
      apply_method = "pending-reboot"
    },
  ]
}

variable "db_parameters" {
  description = "List of database configuration parameter objects for parameter group"

  type = list(object({
    name         = string
    value        = string
    apply_method = optional(string, "pending-reboot")
  }))

  default = []
}

variable "engine_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "16.9"

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+$", var.engine_version))
    error_message = "The `engine_version` must be in the format x.y where x and y are numbers."
  }
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage_gb" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "max_allocated_storage_gb" {
  description = "Max allocated storage in GB"
  type        = number
  default     = 40
}

variable "storage_type" {
  description = "Storage type for RDS"
  type        = string
  default     = "gp3"
}

variable "kms_key_id" {
  description = "KMS key ID for encryption"
  type        = string
  default     = null
}

variable "db_name" {
  description = "Name of the default database"
  type        = string
  default     = null
}

variable "db_port" {
  description = "Database port"
  type        = number
  default     = 5432
}

variable "publicly_accessible" {
  description = "Whether the RDS instance is publicly accessible"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 35
}

variable "monitoring_interval_seconds" {
  description = "Monitoring interval in seconds"
  type        = number
  default     = 60
}

variable "monitoring_role_arn" {
  description = "IAM role ARN for enhanced monitoring"
  type        = string
  default     = null
}

variable "performance_insights_enabled" {
  description = "Whether to enable Performance Insights"
  type        = bool
  default     = true
}

variable "performance_insights_retention_period" {
  description = "Performance Insights retention period in days"
  type        = number
  default     = 7
}

variable "multi_az" {
  description = "Whether to enable Multi-AZ deployment"
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Whether to skip final snapshot on deletion"
  type        = bool
  default     = false
}

variable "final_snapshot_identifier" {
  description = "Identifier for final snapshot"
  type        = string
  default     = null
}

variable "deletion_protection" {
  description = "Whether to enable deletion protection"
  type        = bool
  default     = false
}

variable "maintenance_window" {
  description = "The window to perform maintenance in. Format is `Day:HH:MM-Day:HH:MM`"
  type        = string
  default     = "Sun:02:00-Sun:03:00"
}

variable "backup_window" {
  description = "The daily time range during which backups happen"
  type        = string
  default     = "01:00-02:00"
}

variable "enabled_cloudwatch_logs_exports" {
  description = "Enabled CloudWatch logs exports"
  type        = list(string)
  default     = ["postgresql", "upgrade"]

  validation {
    condition = alltrue([
      for v in var.enabled_cloudwatch_logs_exports :
      contains(["postgresql", "upgrade", "iam-db-auth-error"], v)
    ])
    error_message = "Each value must be one of: postgresql, upgrade, iam-db-auth-error."
  }
}

variable "iam_database_authentication_enabled" {
  description = "Whether to enable IAM database authentication"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "create_read_replica" {
  description = "Whether to create a read replica"
  type        = bool
  default     = false
}

variable "read_replica_count" {
  description = "Number of read replicas to create"
  type        = number
  default     = 0
}

variable "read_replica_instance_class" {
  description = "Instance class for read replicas"
  type        = string
  default     = null
}

variable "read_replica_multi_az" {
  description = "Whether read replicas should be multi-AZ"
  type        = bool
  default     = false
}

variable "subnet_group_name" {
  description = "Name of the DB subnet group"
  type        = string
  default     = null
}

variable "parameter_group_name" {
  description = "Name of the DB parameter group"
  type        = string
  default     = null
}

variable "instance_identifier" {
  description = "RDS instance identifier"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
  default     = []
}

variable "dashboard_name" {
  description = "The name of the CloudWatch dashboard"
  type        = string
  default     = null
}

variable "read_replica_identifier_infix" {
  description = "An infix string added as part of read replica instance identifiers"
  type        = string
  default     = "-replica-"
}

variable "master_user_secret_kms_key_id" {
  description = "KMS key ID for the master user secret"
  type        = string
  default     = null
}

variable "performance_insights_kms_key_id" {
  description = "KMS key ID for performance insights"
  type        = string
  default     = null
}

variable "cloudwatch_alarm_actions" {
  description = <<-EOT
    List of ARNs for actions to execute when this
    alarm transitions into an ALARM state from any other state
    (e.g. SNS topic ARNs)
  EOT

  type    = list(string)
  default = []
}

variable "cloudwatch_ok_actions" {
  description = <<-EOT
    List of ARNs for actions to execute when this
    alarm transitions into an OK state from any other state
    (e.g. SNS topic ARNs)
  EOT

  type    = list(string)
  default = []
}

variable "connection_count_alarm_threshold" {
  description = "Number of database connections beyond which to trigger the alarm"
  type        = number
  default     = 100
}

variable "username" {
  description = "The master user name"
  type        = string
  default     = "postgres"
}

variable "allow_major_version_upgrade" {
  description = "Allow major version upgrade; the upgrade is not automatic, new version must be set explicitly"
  type        = bool
  default     = false
}

variable "auto_minor_version_upgrade" {
  description = "Allow minor version upgrades to be applied automatically to the DB instance during the maintenance window"
  type        = bool
  default     = true
}

variable "apply_immediately" {
  description = "Apply changes immediately; may produce a minor outage if the changes require a reboot"
  type        = bool
  default     = false
}
