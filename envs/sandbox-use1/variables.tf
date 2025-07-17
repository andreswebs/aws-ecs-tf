variable "cluster_name" {
  type        = string
  description = "ECS cluster name"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Public subnet IDs"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Public subnet IDs"
}

variable "acm_certificate_arn" {
  type        = string
  description = "ACM certificate ARN"
}

variable "domain_name" {
  type        = string
  description = "The base domain name used for deployed applications"
}
