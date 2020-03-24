provider "aws" {
  version = "~> 2.0"
}

resource "aws_mq_configuration" "configuration" {
  count          = var.create_configuration ? 1 : 0
  description    = "MQ Configuration"
  name           = "mq-configuration"
  engine_type    = var.engine_type
  engine_version = var.engine_version
  data           = file(var.configuration_file)
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
  security_groups    = [join("", aws_security_group.default.*.id)]
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

resource "aws_security_group" "default" {
  vpc_id = var.vpc_id
  name   = "sample-sg"
}

resource "aws_security_group_rule" "default" {
  count                    = length(var.security_groups) > 0 ? length(var.security_groups) : 0
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "0"
  to_port                  = "0"
  source_security_group_id = element(var.security_groups, count.index)
  security_group_id        = aws_security_group.default.id
}
