output "lb_url" {
  value = "https://${module.ecs_cluster.alb.dns_name}"
}
