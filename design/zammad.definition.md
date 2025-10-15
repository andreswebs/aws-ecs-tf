# Zammad Component Definition

## Description

Zammad component delivers a complete multi-container Helpdesk application stack on AWS ECS, focusing on application and stateful service orchestration while consuming an external shared Application Load Balancer (listeners, host/path routing, target groups), external ACM certificate, and external Route53 records. The module provisions an ECS cluster (Fargate plus EC2 capacity for Elasticsearch and Redis), AWS Cloud Map private DNS namespace (zammad.local) for service discovery, and task definitions + services for: zammad-redis, zammad-elasticsearch, zammad-init, zammad-backup (custom app-level backup task), zammad-railsserver, zammad-scheduler, zammad-websocket, and zammad-nginx (with initialization sequencing). IAM execution and task roles are created with scoped access to RDS PostgreSQL (credentials via SSM parameters), ElastiCache Serverless Memcached, CloudWatch Logs, SSM Parameter Store, Secrets Manager, and service discovery. Data-layer support includes EBS volumes (gp3/io1) for Redis & Elasticsearch encrypted with a single KMS key, ElastiCache Serverless Memcached, and a structured Parameter Store hierarchy (/zammad/database/, /zammad/redis/, application configs). The module defines log groups, health checks, CloudWatch alarms/metrics, encryption settings, and cost-optimized defaults. It excludes load balancer and DNS provisioning, relying on external infrastructure for those concerns.

## Internal Resources

---

aws_ecs_cluster

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster

Inputs: name, setting, capacity_providers, default_capacity_provider_strategy, tags

Outputs: id, arn, name

---

aws_iam_role

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role

Inputs: name, assume_role_policy, description, tags

Outputs: arn, name, unique_id

---

aws_iam_role_policy

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy

Inputs: name, role, policy

Outputs: id, name

---

aws_iam_role_policy_attachment

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment

Inputs: role, policy_arn

Outputs: id

---

aws_ecs_task_definition

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition

Inputs: family, requires_compatibilities, cpu, memory, network_mode, execution_role_arn, task_role_arn, container_definitions, volumes, ephemeral_storage, tags

Outputs: arn, family, revision

---

aws_ecs_service

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service

Inputs: name, cluster, task_definition, desired_count, launch_type, network_configuration, service_registries, load_balancer, deployment_controller, deployment_minimum_healthy_percent, deployment_maximum_percent, propagate_tags, tags

Outputs: id, name, arn

---

aws_service_discovery_private_dns_namespace

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_private_dns_namespace

Inputs: name, description, vpc, tags

Outputs: id, arn, name

---

aws_service_discovery_service

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_service

Inputs: name, dns_config, health_check_config, namespace_id, tags

Outputs: id, arn, name







---

aws_security_group

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group

Inputs: name, description, vpc_id, ingress, egress, tags

Outputs: id, arn, name

---

aws_security_group_rule

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule

Inputs: type, from_port, to_port, protocol, security_group_id, cidr_blocks, source_security_group_id, description

Outputs: id

---

aws_cloudwatch_log_group

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group

Inputs: name, retention_in_days, kms_key_id, tags

Outputs: name, arn



aws_elasticache_serverless_cache

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_serverless_cache

Inputs: cache_name, engine, description, kms_key_arn, tags

Outputs: arn, cache_name, endpoint

---

aws_ebs_volume

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_volume

Inputs: availability_zone, size, type, encrypted, kms_key_id, iops, throughput, tags

Outputs: id, arn

---

aws_cloudwatch_metric_alarm

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm

Inputs: alarm_name, comparison_operator, evaluation_periods, metric_name, namespace, period, statistic, threshold, alarm_description, dimensions, treat_missing_data, tags

Outputs: arn, id, alarm_name

---

aws_ssm_parameter

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter

Inputs: name, type, value, description, overwrite, tier, data_type, tags

Outputs: name, arn

---

aws_secretsmanager_secret

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret

Inputs: name, description, kms_key_id, recovery_window_in_days, tags

Outputs: arn, name

---

aws_secretsmanager_secret_version

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version

Inputs: secret_id, secret_string, version_stages

Outputs: id, version_id, arn

---

aws_kms_key

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key

Inputs: description, enable_key_rotation, policy, tags

Outputs: arn, key_id

---

aws_ecs_capacity_provider

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_capacity_provider

Inputs: name, auto_scaling_group_provider, tags

Outputs: id, name, arn

---

aws_ecs_task_definition (zammad-init)

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition

Inputs: family, requires_compatibilities, cpu, memory, network_mode, execution_role_arn, task_role_arn, container_definitions, volumes, tags

Outputs: arn, family, revision

---

aws_ecs_task_definition (zammad-backup)

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition

Inputs: family, requires_compatibilities, cpu, memory, network_mode, execution_role_arn, task_role_arn, container_definitions, volumes, tags

Outputs: arn, family, revision

---

aws_ecs_task_definition (zammad-redis)

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition

Inputs: family, requires_compatibilities, cpu, memory, network_mode, execution_role_arn, task_role_arn, container_definitions, volumes, tags

Outputs: arn, family, revision

---

aws_ecs_task_definition (zammad-elasticsearch)

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition

Inputs: family, requires_compatibilities, cpu, memory, network_mode, execution_role_arn, task_role_arn, container_definitions, volumes, ephemeral_storage, tags

Outputs: arn, family, revision

---

aws_ecs_task_definition (zammad-railsserver)

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition

Inputs: family, requires_compatibilities, cpu, memory, network_mode, execution_role_arn, task_role_arn, container_definitions, volumes, tags

Outputs: arn, family, revision

---

aws_ecs_task_definition (zammad-scheduler)

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition

Inputs: family, requires_compatibilities, cpu, memory, network_mode, execution_role_arn, task_role_arn, container_definitions, volumes, tags

Outputs: arn, family, revision

---

aws_ecs_task_definition (zammad-websocket)

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition

Inputs: family, requires_compatibilities, cpu, memory, network_mode, execution_role_arn, task_role_arn, container_definitions, volumes, tags

Outputs: arn, family, revision

---

aws_ecs_task_definition (zammad-nginx)

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition

Inputs: family, requires_compatibilities, cpu, memory, network_mode, execution_role_arn, task_role_arn, container_definitions, volumes, tags

Outputs: arn, family, revision

---

aws_ecs_service (zammad-init)

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service

Inputs: name, cluster, task_definition, desired_count, launch_type, network_configuration, deployment_controller, deployment_minimum_healthy_percent, deployment_maximum_percent, propagate_tags, tags

Outputs: id, name, arn

---

aws_ecs_service (zammad-backup)

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service

Inputs: name, cluster, task_definition, desired_count, launch_type, network_configuration, deployment_controller, deployment_minimum_healthy_percent, deployment_maximum_percent, propagate_tags, tags

Outputs: id, name, arn

---

aws_ecs_service (zammad-redis)

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service

Inputs: name, cluster, task_definition, desired_count, launch_type, network_configuration, service_registries, deployment_controller, deployment_minimum_healthy_percent, deployment_maximum_percent, propagate_tags, tags

Outputs: id, name, arn

---

aws_ecs_service (zammad-elasticsearch)

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service

Inputs: name, cluster, task_definition, desired_count, launch_type, network_configuration, service_registries, deployment_controller, deployment_minimum_healthy_percent, deployment_maximum_percent, propagate_tags, tags

Outputs: id, name, arn

---

aws_ecs_service (zammad-railsserver)

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service

Inputs: name, cluster, task_definition, desired_count, launch_type, network_configuration, service_registries, deployment_controller, deployment_minimum_healthy_percent, deployment_maximum_percent, propagate_tags, tags

Outputs: id, name, arn

---

aws_ecs_service (zammad-scheduler)

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service

Inputs: name, cluster, task_definition, desired_count, launch_type, network_configuration, service_registries, deployment_controller, deployment_minimum_healthy_percent, deployment_maximum_percent, propagate_tags, tags

Outputs: id, name, arn

---

aws_ecs_service (zammad-websocket)

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service

Inputs: name, cluster, task_definition, desired_count, launch_type, network_configuration, service_registries, deployment_controller, deployment_minimum_healthy_percent, deployment_maximum_percent, propagate_tags, tags

Outputs: id, name, arn

---

aws_ecs_service (zammad-nginx)

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service

Inputs: name, cluster, task_definition, desired_count, launch_type, network_configuration, service_registries, deployment_controller, deployment_minimum_healthy_percent, deployment_maximum_percent, propagate_tags, tags

Outputs: id, name, arn

---

aws_service_discovery_service (per component)

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_service

Inputs: name, dns_config, health_check_config, namespace_id, tags

Outputs: id, arn, name

---

aws_ecs_capacity_provider (ec2 for elasticsearch)

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_capacity_provider

Inputs: name, auto_scaling_group_provider, tags

Outputs: id, name, arn

---

## External Dependencies

---

External

aws_vpc

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc

Outputs: id, cidr_block

---

External

aws_subnet

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet

Outputs: id

---

External

aws_internet_gateway

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway

Outputs: id

---

External

aws_route_table

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table

Outputs: id

---

External

aws_ecs_capacity_provider

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_capacity_provider

Outputs: name, arn

---

External

aws_iam_policy

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy

Outputs: arn

---

External

aws_acm_certificate (shared or wildcard)

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate

Outputs: arn, domain_name

---

External

aws_route53_zone

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone

Outputs: zone_id, name

---

External

aws_lb

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb

Outputs: arn, dns_name, zone_id

---

External

aws_lb_target_group

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group

Outputs: arn, name

---

External

aws_lb_listener

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener

Outputs: arn

---

External

aws_lb_listener_rule

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule

Outputs: arn

---

External

aws_route53_record

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record

Outputs: fqdn, name

---

External

aws_kms_key (shared encryption)

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key

Outputs: arn

---

External

aws_s3_bucket (backup destination optional)

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket

Outputs: arn, bucket

---

External

aws_cloudwatch_log_group (shared base)

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group

Outputs: name, arn

---

External

aws_secretsmanager_secret (pre-existing global secrets)

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret

Outputs: arn, name

---

External

aws_ssm_parameter (shared parameters)

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter

Outputs: name, arn, value

---

External

aws_iam_role (shared logging/monitoring)

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role

Outputs: arn, name

---

External

aws_security_group (shared egress or baseline)

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group

Outputs: id, arn

---

External

aws_service_discovery_private_dns_namespace (existing namespace if reused)

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_private_dns_namespace

Outputs: id, arn, name

---

External

aws_db_parameter_group (if custom parameters reused)

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_parameter_group

Outputs: name, arn

---

External

aws_elasticache_parameter_group (if custom)

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_parameter_group

Outputs: name, arn

---

External

aws_iam_instance_profile (if any EC2 based sidecar)

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile

Outputs: arn, name

---

External

aws_ecr_repository (images provided externally)

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository

Outputs: repository_url, arn

---

External

aws_cloudwatch_dashboard (shared observability)

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_dashboard

Outputs: dashboard_name

---

External

aws_iam_policy (shared baseline)

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy

Outputs: arn

---

## Pending Clarifications

(none)

## Change Log

Revision 1: Converted Phase 1 records to Phase 2 with documentation URLs, inputs, outputs; external dependencies updated.
Revision 2: Moved load balancer stack (lb, target group, listener, listener rule, route53 record) to External dependencies and removed from Internal.

Phase 2 Status: FINALIZED.
