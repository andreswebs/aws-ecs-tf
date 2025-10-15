variable "zammad_app_name" {
  type = string
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs"
}

# variable "domain_name" {
#   type = string
# }
