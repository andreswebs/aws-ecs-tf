locals {
  partition  = data.aws_partition.current.partition
  region     = data.aws_region.current.region
  account_id = data.aws_caller_identity.current.account_id
  dns_suffix = data.aws_partition.current.dns_suffix
}

locals {
  engine                         = "postgres"
  engine_major_version           = split(".", var.engine_version)[0]
  parameter_group_family         = "${local.engine}${local.engine_major_version}"
  read_replica_identifier_prefix = "${var.instance_identifier}${var.read_replica_identifier_infix}"
  parameter_group_name           = var.parameter_group_name != null && var.parameter_group_name != "" ? var.parameter_group_name : var.instance_identifier
  read_replica_instance_class    = var.read_replica_instance_class != null && var.read_replica_instance_class != "" ? var.read_replica_instance_class : var.instance_class
  monitoring_enabled             = var.monitoring_role_arn != null && var.monitoring_role_arn != ""

  db_parameters_set     = setunion(var.db_default_parameters, var.db_parameters)
  db_parameters_map     = { for p in local.db_parameters_set : p.name => p }
  db_parameters_names   = sort(keys(local.db_parameters_map))
  db_parameters_ordered = tolist([for n in local.db_parameters_names : lookup(local.db_parameters_map, n)])
}

locals {
  dashboard_name              = var.dashboard_name != null && var.dashboard_name != "" ? var.dashboard_name : "rds-${var.instance_identifier}"
  cpu_utilization_alarm_name  = "rds-cpu-utilization-${var.instance_identifier}"
  free_memory_alarm_name      = "rds-free-memory-${var.instance_identifier}"
  free_storage_alarm_name     = "rds-free-storage-${var.instance_identifier}"
  connection_count_alarm_name = "rds-connection-count-${var.instance_identifier}"
  replica_lag_alarm_name      = "rds-replica-lag-${var.instance_identifier}"
}

