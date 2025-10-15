data "aws_region" "current" {}

data "aws_subnet" "selected" {
  id = var.private_subnet_ids[0]
}
