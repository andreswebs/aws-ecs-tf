variable "name" {
  type = string
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Subnet IDs"
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

variable "acm_certificate_arns" {
  description = "List of ACM certificate ARNs attached to the HTTPS listener"
  type        = list(string)

  validation {
    error_message = "At least one ACM certificate ARN is required."
    condition     = length(var.acm_certificate_arns) > 0
  }
}
