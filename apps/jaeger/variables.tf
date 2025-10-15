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
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Subnet IDs"
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
  default     = "t3a.medium"
  description = "ECS container-instance type"
}

# variable "ssh_key_name" {
#   type        = string
#   description = "ECS container-instance SSH key-pair name"
# }

variable "log_retention_in_days" {
  type        = number
  default     = 30
  description = "CloudWatch Logs retention in days"
}

variable "instance_profile_name" {
  type        = string
  description = "ECS container-instance IAM profile name"
}

variable "execution_role_arn" {
  type        = string
  description = "ECS 'Task Execution Role' ARN"
}

variable "task_role_arn" {
  type        = string
  description = "ECS 'Task Role' ARN"
}

variable "container_port" {
  type        = number
  description = "The app container exposed port"
  default     = 8080
}

variable "allowed_cidrs" {
  type        = list(string)
  description = "Allowed CIDRs to access"
  default     = []
}

variable "jaeger_es_server_urls" {
  type        = string
  description = "Value passed to the Jaeger server `ES_SERVER_URLS` environment variable"
}

variable "acm_certificate_arn" {
  type        = string
  description = "ACM certificate ARN for the service domain name"
}

variable "route53_zone_id" {
  type        = string
  description = "The hosted zone ID where an alias record will be created"
}
