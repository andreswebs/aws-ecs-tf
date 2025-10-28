variable "zammad_app_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs"
}

variable "domain_name" {
  type = string
}

variable "dbinit_lambda_image_uri" {
  type    = string
  default = null
}

variable "kms_key_name" {
  type = string
}

variable "acm_certificate_arn" {
  type = string
}
