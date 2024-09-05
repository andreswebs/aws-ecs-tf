variable "cluster_name" {
  type        = string
  description = "ECS cluster name"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Subnet IDs"
  validation {
    condition     = length(var.private_subnet_ids) > 0
    error_message = "Must contain at least one."
  }
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Subnet IDs"
  validation {
    condition     = length(var.public_subnet_ids) > 0
    error_message = "Must contain at least one."
  }
}

variable "cluster_desired_capacity" {
  type        = number
  default     = 1
  description = "ECS cluster ASG desired capacity"
}

variable "cluster_max_size" {
  type        = number
  default     = 3
  description = "ECS cluster ASG maximum instance count"
}

variable "cluster_min_size" {
  type        = number
  default     = 1
  description = "ECS cluster ASG minimum instance count"
}

variable "instance_type" {
  type        = string
  default     = "t3a.small"
  description = "ECS container-instance type"
}

variable "log_retention_in_days" {
  type        = number
  default     = 30
  description = "CloudWatch Logs retention in days"
}


########
## wg
########

variable "wg_serverurl" {
  description = "The URL of the WireGuard server"
  type        = string
}

variable "wg_peers" {
  description = "The peers for the WireGuard server"
  type        = string
}
