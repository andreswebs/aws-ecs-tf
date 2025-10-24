variable "name" {
  type = string
}

variable "log_group_name_prefix" {
  description = "Log group name prefix"
  type        = string
  default     = "/aws/ecs/"
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

variable "capacity_providers" {
  description = "Optional) Set of names of one or more capacity providers to associate with the cluster"
  type        = list(string)
  default     = ["FARGATE", "FARGATE_SPOT"]
}

variable "default_capacity_provider_strategies" {
  type = list(object({
    capacity_provider = string
    weight            = number
    base              = number
  }))

  description = "(Optional) Set of capacity provider strategies to use by default for the cluster"

  default = [{
    capacity_provider = "FARGATE"
    base              = 1
    weight            = 100
  }]
}
