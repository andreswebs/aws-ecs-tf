module "efs" {
  source     = "andreswebs/efs/aws"
  version    = "0.3.0"
  name       = var.cluster_name
  subnet_ids = var.private_subnet_ids

  enable_client_root_access = true
}
