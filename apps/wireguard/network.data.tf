data "aws_subnet" "prv" {
  for_each = toset(var.private_subnet_ids)
  id       = each.value
}

data "aws_subnet" "pub" {
  for_each = toset(var.public_subnet_ids)
  id       = each.value
}

data "aws_vpc" "this" {
  id = var.vpc_id
}

locals {
  private_subnet_cidrs_ipv4 = [for s in data.aws_subnet.prv : s.cidr_block]
}
