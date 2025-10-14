variable "name" {
  type        = string
  description = "Target group name; a count suffix will be appended to it"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "protocol" {
  type    = string
  default = "HTTP"

  validation {
    condition     = contains(["GENEVE", "HTTP", "HTTPS", "TCP", "TCP_UDP", "TLS", "UDP"], var.protocol)
    error_message = "The `protocol` must be one of: GENEVE, HTTP, HTTPS, TCP, TCP_UDP, TLS, UDP."
  }
}

variable "protocol_version" {
  type    = string
  default = "HTTP1"

  validation {
    condition     = contains(["HTTP1", "HTTP2", "GRPC"], var.protocol_version)
    error_message = "The `protocol_version` must be one of: HTTP1, HTTP2, GRPC."
  }
}

variable "target_port" {
  type        = number
  description = "The target application port"

  validation {
    condition     = var.target_port >= 1 && var.target_port <= 65535
    error_message = "The `target_port` must be between 1-65535."
  }
}

variable "target_type" {
  type    = string
  default = "ip"

  validation {
    condition     = contains(["ip", "instance"], var.target_type)
    error_message = "The `target_type` must be one of: instance, ip."
  }
}

variable "health_check" {
  type = object({
    enabled             = optional(bool, true)
    protocol            = optional(string, "HTTP")
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
