module "efs" {
  source                        = "andreswebs/efs/aws"
  version                       = "0.7.0"
  name                          = "${var.name}-zammad-storage"
  subnet_ids                    = var.private_subnet_ids
  allowed_security_group_id     = aws_security_group.backend.id
  enable_allowed_security_group = true
  enable_client_root_access     = true
}
