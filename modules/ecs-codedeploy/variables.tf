variable "ecs_cluster_name" {
  type        = string
  description = "ECS Cluster name"
}

variable "ecs_service_name" {
  type        = string
  description = "ECS Service name"
}

variable "ecs_task_def_arn" {
  type        = string
  description = "ECS Task definition Arn"
}

variable "codedeploy_app_name" {
  type        = string
  description = "CodeDeploy Application name"
}

variable "codedeploy_service_role_arn" {
  type        = string
  description = "CodeDeploy service role ARN"
}

variable "container_name" {
  type        = string
  description = "Container name"
}

variable "container_port" {
  type        = number
  description = "Container port"
}


variable "codedeploy_role_name" {
  type        = string
  description = "CodeDeploy IAM Role name"
}

variable "deployment_group_name" {
  type        = string
  description = "CodeDeploy Deployment group name"
}

variable "deployment_config_name" {
  type        = string
  description = "CodeDeploy Deployment Config name"
  default     = "CodeDeployDefault.ECSAllAtOnce"
}

variable "ecs_task_termination_wait_time_minutes" {
  type        = number
  description = "ECS task termination wait time in minutes"
  default     = 5
}

variable "auto_rollback_events" {
  type        = list(string)
  description = "The event type or types that trigger a rollback"
  default     = ["DEPLOYMENT_FAILURE"]

  validation {
    condition     = length(var.auto_rollback_events) <= 3 && alltrue([for v in var.auto_rollback_events : contains(["DEPLOYMENT_FAILURE", "DEPLOYMENT_STOP_ON_ALARM", "DEPLOYMENT_STOP_ON_REQUEST"], v)])
    error_message = "`auto_rollback_events` must be a list of at most 3 items, and only `DEPLOYMENT_FAILURE`, `DEPLOYMENT_STOP_ON_ALARM`, and `DEPLOYMENT_STOP_ON_REQUEST` are allowed."
  }
}

variable "deployment_action_on_timeout" {
  type        = string
  description = "When to reroute traffic from an original environment to a replacement environment in a blue/green deployment"
  default     = "CONTINUE_DEPLOYMENT"

  validation {
    condition     = contains(["CONTINUE_DEPLOYMENT", "STOP_DEPLOYMENT"], var.deployment_action_on_timeout)
    error_message = "Only `CONTINUE_DEPLOYMENT` or `STOP_DEPLOYMENT` are allowed."
  }
}

variable "alb_listener_arn" {
  type        = string
  description = "ALB listener ARN"
}

variable "alb_test_listener_arns" {
  type        = list(string)
  description = "List of Arns of ALB Test listners"
  default     = []
}

variable "alb_target_group_names" {
  type        = list(string)
  description = "ALB target group names"

  validation {
    condition     = length(var.auto_rollback_events) == 2
    error_message = "Must contain exactly 2 items"
  }
}
