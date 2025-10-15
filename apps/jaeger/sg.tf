resource "aws_security_group" "lb" {
  vpc_id = var.vpc_id

  revoke_rules_on_delete = true

  ingress {
    protocol    = "TCP"
    from_port   = 443
    to_port     = 443
    cidr_blocks = var.allowed_cidrs
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = format("ecs-%s-lb", var.cluster_name)
  }

  name = format("ecs-%s-lb", var.cluster_name)

}

resource "aws_security_group" "instance" {
  vpc_id = var.vpc_id

  revoke_rules_on_delete = true

  ingress {
    protocol        = "-1"
    from_port       = 0
    to_port         = 0
    security_groups = [aws_security_group.lb.id]
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
