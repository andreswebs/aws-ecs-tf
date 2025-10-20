
resource "aws_db_parameter_group" "this" {
  name        = local.parameter_group_name
  family      = local.parameter_group_family
  description = var.parameter_group_description

  dynamic "parameter" {
    for_each = local.db_parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }

  tags = merge(var.tags, {
    Name = local.parameter_group_name
  })
}

resource "aws_db_instance" "this" {
  identifier = var.instance_identifier

  apply_immediately = var.apply_immediately

  engine         = local.engine
  engine_version = var.engine_version
  instance_class = var.instance_class
  db_name        = var.db_name
  port           = var.db_port

  allow_major_version_upgrade = var.allow_major_version_upgrade
  auto_minor_version_upgrade  = var.auto_minor_version_upgrade

  allocated_storage     = var.allocated_storage_gb
  max_allocated_storage = var.max_allocated_storage_gb
  storage_type          = var.storage_type
  storage_encrypted     = true
  kms_key_id            = var.kms_key_id

  username                      = var.username
  manage_master_user_password   = true
  master_user_secret_kms_key_id = var.master_user_secret_kms_key_id

  db_subnet_group_name   = var.subnet_group_name
  vpc_security_group_ids = var.security_group_ids
  publicly_accessible    = var.publicly_accessible

  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window

  monitoring_interval                   = var.monitoring_interval_seconds
  monitoring_role_arn                   = var.monitoring_role_arn
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_retention_period
  performance_insights_kms_key_id       = var.performance_insights_kms_key_id

  multi_az                  = var.multi_az
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.final_snapshot_identifier
  deletion_protection       = var.deletion_protection

  parameter_group_name = aws_db_parameter_group.this.name

  iam_database_authentication_enabled = var.iam_database_authentication_enabled

  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  tags = merge(var.tags, {
    Name = var.instance_identifier
  })
}

resource "aws_db_instance" "read_replica" {
  count = var.create_read_replica ? var.read_replica_count : 0

  identifier = "${local.read_replica_identifier_prefix}${count.index + 1}"

  instance_class      = local.read_replica_instance_class
  replicate_source_db = aws_db_instance.this.id

  db_subnet_group_name   = var.subnet_group_name
  vpc_security_group_ids = var.security_group_ids
  publicly_accessible    = var.publicly_accessible

  monitoring_interval                   = var.monitoring_interval_seconds
  monitoring_role_arn                   = var.monitoring_role_arn
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_retention_period
  performance_insights_kms_key_id       = var.performance_insights_kms_key_id

  multi_az = var.read_replica_multi_az

  parameter_group_name = aws_db_parameter_group.this.name

  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  tags = merge(var.tags, {
    Name = "${local.read_replica_identifier_prefix}${count.index + 1}"
  })
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  alarm_name          = local.cpu_utilization_alarm_name
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This metric monitors RDS CPU utilization"
  alarm_actions       = var.cloudwatch_alarm_actions
  ok_actions          = var.cloudwatch_ok_actions

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.this.identifier
  }

  tags = merge(var.tags, {
    Name = local.cpu_utilization_alarm_name
  })
}

resource "aws_cloudwatch_metric_alarm" "free_memory" {
  alarm_name          = local.free_memory_alarm_name
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 100000000 # 100MB
  alarm_description   = "This metric monitors RDS free memory"
  alarm_actions       = var.cloudwatch_alarm_actions
  ok_actions          = var.cloudwatch_ok_actions

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.this.identifier
  }

  tags = merge(var.tags, {
    Name = local.free_memory_alarm_name
  })
}

resource "aws_cloudwatch_metric_alarm" "free_storage" {
  alarm_name          = local.free_storage_alarm_name
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 1000000000 # 1GB
  alarm_description   = "This metric monitors RDS free storage space"
  alarm_actions       = var.cloudwatch_alarm_actions
  ok_actions          = var.cloudwatch_ok_actions

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.this.identifier
  }

  tags = merge(var.tags, {
    Name = local.free_storage_alarm_name
  })
}

resource "aws_cloudwatch_metric_alarm" "connection_count" {
  alarm_name          = local.connection_count_alarm_name
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = var.connection_count_alarm_threshold
  alarm_description   = "This metric monitors RDS connection count"
  alarm_actions       = var.cloudwatch_alarm_actions
  ok_actions          = var.cloudwatch_ok_actions

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.this.identifier
  }

  tags = merge(var.tags, {
    Name = local.connection_count_alarm_name
  })
}

resource "aws_cloudwatch_metric_alarm" "replica_lag" {
  count               = var.create_read_replica ? var.read_replica_count : 0
  alarm_name          = "${local.replica_lag_alarm_name}-${count.index + 1}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "ReplicaLag"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 300 # 5 minutes
  alarm_description   = "This metric monitors RDS replica lag"
  alarm_actions       = var.cloudwatch_alarm_actions
  ok_actions          = var.cloudwatch_ok_actions

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.read_replica[count.index].identifier
  }

  tags = merge(var.tags, {
    Name = "${local.replica_lag_alarm_name}-${count.index + 1}"
  })
}

resource "aws_cloudwatch_dashboard" "this" {
  dashboard_name = local.dashboard_name

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", aws_db_instance.this.identifier],
            ["AWS/RDS", "FreeableMemory", "DBInstanceIdentifier", aws_db_instance.this.identifier],
            ["AWS/RDS", "FreeStorageSpace", "DBInstanceIdentifier", aws_db_instance.this.identifier],
            ["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", aws_db_instance.this.identifier]
          ]
          period = 300
          stat   = "Average"
          region = local.region
          title  = "RDS Performance Metrics"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/RDS", "ReadIOPS", "DBInstanceIdentifier", aws_db_instance.this.identifier],
            ["AWS/RDS", "WriteIOPS", "DBInstanceIdentifier", aws_db_instance.this.identifier],
            ["AWS/RDS", "ReadLatency", "DBInstanceIdentifier", aws_db_instance.this.identifier],
            ["AWS/RDS", "WriteLatency", "DBInstanceIdentifier", aws_db_instance.this.identifier]
          ]
          period = 300
          stat   = "Average"
          region = local.region
          title  = "RDS I/O Metrics"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/RDS", "ReplicaLag", "DBInstanceIdentifier", aws_db_instance.this.identifier]
          ]
          period = 300
          stat   = "Average"
          region = local.region
          title  = "Replication Lag"
        }
      },
      {
        type   = "log"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          query  = "SOURCE '/aws/rds/instance/${aws_db_instance.this.identifier}/postgresql' | filter @message like /ERROR/ | fields @timestamp, @message\n| sort @timestamp desc\n| limit 100"
          region = local.region
          title  = "PostgreSQL Error Logs"
          view   = "table"
        }
      },
    ]
  })
}
