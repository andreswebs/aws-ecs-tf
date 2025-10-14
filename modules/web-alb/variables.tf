variable "name" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "acm_certificate_arns" {
  type = list(string)
  validation {
    error_message = "At least one ACM certificate ARN is required."
    condition     = length(var.acm_certificate_arns) > 0
  }
}

variable "security_group_name_suffix" {
  type    = string
  default = "-alb"
}

variable "enable_deletion_protection" {
  type    = bool
  default = false
}
