resource "aws_codedeploy_app" "this" {
  compute_platform = "ECS"
  name             = var.codedeploy_app_name
}

resource "aws_codedeploy_deployment_group" "this" {
  app_name               = aws_codedeploy_app.this.name
  deployment_config_name = var.codedeploy_deployment_config_name
  deployment_group_name  = var.codedeploy_deployment_group_name
  service_role_arn       = var.codedeploy_service_role_arn

  auto_rollback_configuration {
    enabled = true
    events  = var.auto_rollback_events
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = var.deployment_action_on_timeout
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = var.ecs_task_termination_wait_time_minutes
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = var.ecs_cluster_name
    service_name = var.ecs_service_name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [var.alb_listener_arn]
      }

      test_traffic_route {
        listener_arns = compact([var.alb_test_listener_arn])
      }

      dynamic "target_group" {
        for_each = var.alb_target_group_names
        iterator = tg_name
        content {
          name = tg_name.value
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [blue_green_deployment_config]
  }
}
