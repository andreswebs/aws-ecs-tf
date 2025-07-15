locals {
  task_port = 80
}

resource "aws_security_group" "task" {
  vpc_id = var.vpc_id

  revoke_rules_on_delete = true

  tags = {
    Name = format("ecs-%s-task", var.cluster_name)
  }

  name = format("ecs-%s-task", var.cluster_name)
}

resource "aws_vpc_security_group_ingress_rule" "task_from_alb" {
  security_group_id            = aws_security_group.task.id
  ip_protocol                  = "tcp"
  from_port                    = local.task_port
  to_port                      = local.task_port
  referenced_security_group_id = module.ecs_cluster.alb_sg.id

  description = "Allow HTTP"

  tags = {
    Name = format("ecs-%s-task-alb-http", var.cluster_name)
  }
}

resource "aws_vpc_security_group_egress_rule" "alb_to_task" {
  security_group_id            = module.ecs_cluster.alb_sg.id
  ip_protocol                  = "tcp"
  from_port                    = local.task_port
  to_port                      = local.task_port
  referenced_security_group_id = aws_security_group.task.id

  description = "Allow HTTP"

  tags = {
    Name = format("ecs-%s-alb-task-http", var.cluster_name)
  }
}


/*

  ALB:

  revoke_rules_on_delete = true

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }


  TASK:

  ingress {
    description      = "Traffic from ALB"
    from_port        = var.container_port
    to_port          = var.container_port
    protocol         = "tcp"
    security_groups  = [aws_security_group.alb.id]
  }

*/
