resource "aws_security_group" "lb" {
  name   = format("ecs-%s-lb", var.cluster_name)
  vpc_id = var.vpc_id

  revoke_rules_on_delete = true

  tags = {
    Name = format("ecs-%s-lb", var.cluster_name)
  }
}

resource "aws_vpc_security_group_ingress_rule" "lb_udp" {
  security_group_id = aws_security_group.lb.id
  ip_protocol       = "UDP"
  from_port         = 51820
  to_port           = 51820
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "lb_allow_all" {
  security_group_id = aws_security_group.lb.id
  ip_protocol       = "-1"
  from_port         = 0
  to_port           = 0
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_security_group" "instance" {
  name   = format("ecs-%s-instance", var.cluster_name)
  vpc_id = var.vpc_id

  revoke_rules_on_delete = true

  tags = {
    Name = format("ecs-%s-instance", var.cluster_name)
  }
}

resource "aws_vpc_security_group_egress_rule" "instance_allow_all" {
  security_group_id = aws_security_group.instance.id
  ip_protocol       = "-1"
  from_port         = 0
  to_port           = 0
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "instance_udp" {
  security_group_id            = aws_security_group.instance.id
  referenced_security_group_id = aws_security_group.lb.id
  ip_protocol                  = "UDP"
  from_port                    = 51820
  to_port                      = 51820
}
