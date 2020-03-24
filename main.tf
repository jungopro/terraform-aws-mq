provider "aws" {
  version = "~> 2.0"
}

resource "aws_mq_configuration" "configuration" {
  count          = var.create_configuration
  description    = " MQ Configuration"
  name           = "mq-configuration"
  engine_type    = var.engine_type
  engine_version = var.engine_version
  data           = file(var.configuration_file)
}

resource "aws_security_group" "group" {
  name        = "allow_all"
  description = "Allow all"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "rule" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/16"]
  security_group_id = aws_security_group.group.id
}

resource "random_password" "mq_password" {
  length = 16
  special = true
  min_upper = 1
  min_lower = 1
  min_numeric = 1
  min_special = 1

  keepers = {
    broker_name = "mq-broker"
  }
}

resource "aws_mq_broker" "broker" {
  broker_name = var.broker_name == "" ? "mq-broker" : var.broker_name
  
  configuration {
    id       = var.create_configuration ? aws_mq_configuration.configuration.0.id : var.configuration_id
    revision = var.create_configuration ? aws_mq_configuration.configuration.0.latest_revision : var.configuration_revision
  }

  engine_type        = var.engine_type
  engine_version     = var.engine_version
  host_instance_type = var.host_instance_type
  security_groups    = var.create_security_groups ? aws_security_group.groups.*.id : [var.security_group_ids]

  user {
    username = var.mq_username
    password = var.mq_password == "" ? random_password.mq_password.result : var.mq_password
  }
}
