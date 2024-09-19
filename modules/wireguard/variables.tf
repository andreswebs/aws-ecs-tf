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
  default     = 2
  description = "ECS cluster ASG desired capacity"
}

variable "cluster_max_size" {
  type        = number
  default     = 4
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

variable "container_port" {
  type        = number
  description = "The app exposed port"
  default     = 51820
}

variable "health_check_port" {
  type        = number
  description = "The health check exposed port"
  default     = 9000
}

variable "health_check_path" {
  type        = string
  description = "The health check path"
  default     = "/"
}

variable "health_check_protocol" {
  type        = string
  description = "The health check protocol"
  default     = "HTTP"
}

variable "force_new_deployment" {
  type        = bool
  description = "Force new deployment?"
  default     = true
}

variable "log_group_name_prefix" {
  description = "Log group name prefix"
  type        = string
  default     = "/aws/ecs/"
}

variable "log_stream_prefix" {
  description = "Log stream prefix"
  type        = string
  default     = "wireguard"
}

variable "log_retention_in_days" {
  description = "Log retention days"
  type        = number
  default     = 30
}

##############
## ECS IAM
##############

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
## WG
#############

variable "app_uid" {
  type    = number
  default = 2000
}

variable "app_gid" {
  type    = number
  default = 2000
}

variable "efs_root_dir_path" {
  type    = string
  default = "/wireguard"
}

variable "wg_serverurl" {
  description = "The URL of the WireGuard server"
  type        = string
}

variable "wg_peers" {
  description = "The peers for the WireGuard server"
  type        = string
}

variable "wg_allowedips" {
  description = "The allowed IPs for the WireGuard server, used for split tunneling"
  type        = string
  default     = "10.0.0.0/8"
}

variable "wg_image" {
  description = "The WireGuard container image to use"
  type        = string
  default     = "linuxserver/wireguard:latest"
}

variable "wg_docker_mods" {
  description = "Docker Mods to use"
  type        = string
  default     = "andreswebs/wghealth:latest"
}

variable "wg_internal_subnet" {
  type    = string
  description = "The internal subnet used by WireGuard; only change if it clashes with existing subnet ranges"
  default = "10.13.13.0"
}
