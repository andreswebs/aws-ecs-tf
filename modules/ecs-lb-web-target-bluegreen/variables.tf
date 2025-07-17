variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "acm_certificate_arn" {
  type        = string
  description = "ACM certificate ARN"
}

variable "load_balancer_arn" {
  type        = string
  description = "Load balancer ARN"
}

variable "target_group_name" {
  type        = string
  description = "Target group name; a count suffix will be appended to it"
}

variable "target_port" {
  type        = number
  description = "The target application port"

  validation {
    condition     = var.target_port >= 1 && var.target_port <= 65535
    error_message = "The `target_port` must be between 1-65535."
  }
}

variable "health_check" {
  type = object({
    enabled             = optional(bool, true)
    port                = optional(string, "traffic-port")
    path                = optional(string, "/")
    matcher             = optional(string, "200-499")
    interval            = optional(number, 10)
    timeout             = optional(number, 5)
    unhealthy_threshold = optional(number, 2)
    healthy_threshold   = optional(number, 2)
  })

  description = "Target group health check configuration"

  default = {}
}
