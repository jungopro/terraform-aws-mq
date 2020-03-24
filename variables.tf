variable "engine_type" {
  description = "(Required) The type of broker engine"
  default = "ActiveMQ"
}

variable "engine_version" {
  description = "(Required) The version of the broker engine."
  default = "5.15.0"
}

variable "create_configuration" {
  description = "Should we create mq configuration or use a pre-existing one. If true, please provide input for var.configuration_data below or keep the deafult. if false, please provide input for var.configuration_id and var.configuration_revision below"
  default = true
}

variable "configuration_file" {
  description = "path to a config file for the mq configuration"
  default = "./config.xml"
}

variable "configuration_id" {
  description = "The Configuration ID. only supply if var.create_configuration = false"
  default = ""
}

variable "configuration_revision" {
  description = "The Configuration revision. only supply if var.create_configuration = false"
  default = ""
}

variable "deployment_mode" {
  description = "(Optional) The deployment mode of the broker. Supported: SINGLE_INSTANCE and ACTIVE_STANDBY_MULTI_AZ"
  default = "SINGLE_INSTANCE"
}

variable "broker_name" {
  description = "(Required) The name of the broker. leave empty to auto generate"
  default = ""
}

variable "host_instance_type" {
  description = "(Required) The broker's instance type. e.g. mq.t2.micro or mq.m4.large"
  default = "mq.t2.micro"
}

variable "create_security_groups" {
  description = "Should we create mq security group(s) or use a pre-existing one. If true, please provide input for var.vpc_id below. If false, please provide input for var.security_group_ids below"
  default = true
}

variable "vpc_id" {
  description = "the vpc id"
  default = ""
}

variable "security_group_ids" {
  type = list(string)
  description = "(Required) The list of security group IDs assigned to the broker"
  default = []
}

variable "mq_username" {
  description = "(Required) The username of the user."
  default = "MQAdmin"
}

variable "mq_password" {
  description = "(Required) The password of the user. It must be 12 to 250 characters long, at least 4 unique characters, and must not contain commas. if you wish to autogenerate, leave empty"
  default = ""
}
