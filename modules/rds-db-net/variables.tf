variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) > 0
    error_message = "At least one subnet ID must be provided."
  }
}

variable "db_security_group_name" {
  description = "The name of the generated security group for the database"
  type        = string
  default     = null
}

variable "db_security_group_description" {
  description = "Description for the generated security group"
  type        = string
  default     = null
}

variable "db_subnet_group_name" {
  description = "The name of the generated subnet group for the database"
  type        = string
  default     = null
}

variable "tags" {
  description = "Map of tags to apply to all created resources"
  type        = map(string)
  default     = {}
}

variable "ingress_rules_ipv4" {
  description = "List of ingress rule objects"

  type = list(object({
    name        = optional(string)
    description = optional(string)
    ip_protocol = optional(string, "tcp")
    from_port   = optional(number, 5432)
    to_port     = optional(number, 5432)
    cidr_ipv4   = string
  }))

  default = []
}

variable "egress_rules_ipv4" {
  description = "List of egress rule objects"

  type = list(object({
    name        = optional(string)
    description = optional(string)
    ip_protocol = optional(string, "tcp")
    from_port   = number
    to_port     = number
    cidr_ipv4   = string
  }))

  default = [{
    name        = "allow-all-egress-ipv4"
    description = "Allow all egress IPv4 traffic"
    ip_protocol = "-1"
    from_port   = -1
    to_port     = -1
    cidr_ipv4   = "0.0.0.0/0"
  }]
}
