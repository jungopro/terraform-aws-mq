# Create Amazon MQ Service in AWS

This Terraform module deploys Amazon MQ service to AWS

**Usage**

```hcl
module "mq" {
  source     = "jungopro/mq/aws"
  subnet_ids = ["subnet-********"]
  vpc_id     = "vpc-*******"
}
```

**Exmplae with custom values**

```hcl
module "mq" {
  source             = "jungopro/mq/aws"
  version            = "1.7.0"

  # The below inputs are pre-defined outputs from terraform-aws-modules/vpc/aws official module

  subnet_ids         = [element(module.vpc.private_subnets, 0)]
  security_group_ids = [module.vpc.default_security_group_id]
  vpc_id             = module.vpc.default_vpc_id

  # Override the default configuration file

  configuration_file = "/tmp/my-config.xml"

  rules = {
    allow_all_inbound = {
      type        = "ingress"
      protocol    = "tcp"
      from_port   = "0"
      to_port     = "0"
      cidr_blocks = [
        "0.0.0.0/0",
      ]
    }
  }
}
```