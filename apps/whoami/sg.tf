resource "aws_security_group" "alb" {
  vpc_id = var.vpc_id

  revoke_rules_on_delete = true

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = format("ecs-%s-alb", var.cluster_name)
  }

  name = format("ecs-%s-alb", var.cluster_name)

}

resource "aws_security_group" "instance" {
  vpc_id = var.vpc_id

  revoke_rules_on_delete = true

  ingress {
    protocol        = "-1"
    from_port       = 0
    to_port         = 0
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = format("ecs-%s-instance", var.cluster_name)
  }

  name = format("ecs-%s-instance", var.cluster_name)

}
