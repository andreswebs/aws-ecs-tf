module "wireguard" {
  source             = "../../modules/wireguard"
  cluster_name       = var.cluster_name
  vpc_id             = var.vpc_id
  private_subnet_ids = var.private_subnet_ids
  public_subnet_ids  = var.public_subnet_ids
  wg_serverurl       = var.wg_serverurl
  wg_peers           = var.wg_peers
}
