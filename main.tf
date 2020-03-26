resource "aws_mq_configuration" "configuration" {
  count          = var.create_configuration ? 1 : 0
  description    = "MQ Configuration"
  name           = "mq-configuration"
  engine_type    = var.engine_type
  engine_version = var.engine_version
  data           = var.configuration_file != "config.xml" ? var.configuration_file : file("${path.root}/${var.configuration_file}")
}

resource "random_password" "mq_password" {
  length           = 16
  special          = true
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
  override_special = "!@#$%&*()_+{}<>?"

  keepers = {
    broker_name = "mq-broker"
  }
}

resource "aws_mq_broker" "broker" {
  broker_name        = var.broker_name == "" ? "mq-broker" : var.broker_name
  deployment_mode    = var.deployment_mode
  engine_type        = var.engine_type
  engine_version     = var.engine_version
  host_instance_type = var.host_instance_type
  security_groups    = concat(aws_security_group.group.*.id, var.security_group_ids)
  subnet_ids         = var.subnet_ids

  configuration {
    id       = var.create_configuration ? aws_mq_configuration.configuration.0.id : var.configuration_id
    revision = var.create_configuration ? aws_mq_configuration.configuration.0.latest_revision : var.configuration_revision
  }

  user {
    username       = var.mq_username
    password       = var.mq_password == "" ? random_password.mq_password.result : var.mq_password
    groups         = ["admin"]
    console_access = true
  }
}

resource "aws_security_group" "group" {
  vpc_id = var.vpc_id
  name   = var.security_group_name == "" ? "mq-broker-sec-group" : var.security_group_name
}

resource "aws_security_group_rule" "rule" {
  for_each          = var.rules
  type              = lookup(each.value, "type")
  protocol          = lookup(each.value, "protocol")
  from_port         = lookup(each.value, "from_port")
  to_port           = lookup(each.value, "to_port")
  cidr_blocks       = lookup(each.value, "cidr_blocks")
  security_group_id = aws_security_group.group.id
}
