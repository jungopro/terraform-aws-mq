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
  override_special = "!@#$%&*()_=+[]{}<>:?"

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
  security_groups    = var.security_group_ids

  user {
    username = var.mq_username
    password = var.mq_password == "" ? random_password.mq_password.result : var.mq_password
  }
}
