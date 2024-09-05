variable "cluster_name" {
  type = string
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

# variable "container_port" {
#   type        = number
#   description = "The app container exposed port"
#   default     = 8080
# }

variable "task_role_name" {
  description = "The name of the task role"
  type        = string
  default     = "ecs-task-wireguard"
}

variable "execution_role_name" {
  description = "The name of the execution role"
  type        = string
  default     = "ecs-execution-wireguard"
}

variable "instance_role_name" {
  description = "The name of the instance role"
  type        = string
  default     = "ecs-instance-wireguard"
}

variable "instance_profile_name" {
  description = "The name of the instance profile"
  type        = string
  default     = "ecs-wireguard"
}

#############

variable "app_uid" {
  type    = number
  default = 2000
}

variable "app_gid" {
  type    = number
  default = 2000
}

variable "root_dir_permissions" {
  type    = number
  default = 0750
}

variable "root_dir_path" {
  type    = string
  default = "/wireguard"
}
