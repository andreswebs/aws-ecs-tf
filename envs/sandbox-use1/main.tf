
module "zammad" {
  source             = "../../apps/zammad"
  name               = var.zammad_app_name
  private_subnet_ids = var.private_subnet_ids
}
