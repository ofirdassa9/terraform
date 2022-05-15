locals {
	vars = jsondecode(file("${path.cwd}/modules/vars.tfvars.json"))
}

provider "aws" {
  profile = "personal"
  region = "us-east-1"
}

module "vpc" {
  source = "./modules/vpc"
  vpc_name = local.vars.vpc_name
  vpc_cidr_block = local.vars.vpc_cidr_block
  public_subnets_az = local.vars.public_subnets_az
  public_subnets_cidr = local.vars.public_subnets_cidr
  environment = local.vars.environment
  enable_dns_support = local.vars.enable_dns_support
  enable_dns_hostnames = local.vars.enable_dns_hostnames
}

module "security_group" {
  source         = "./modules/security_group"
  vpc_id         = module.vpc.aws_vpc_id
  vpc_cidr_block = module.vpc.vpc_cidr_block
}

module "db_subnet_group" {
  source = "./modules/db_subnet_group"
  subnet_ids = module.vpc.aws_subnet_id
}

module "mysql-rds" {
  source = "./modules/mysql-rds"
  count                  = length(module.vpc.aws_vpc_id)
  allocated_storage      = local.vars.allocated_storage
  max_allocated_storage  = local.vars.max_allocated_storage
  engine                 = local.vars.engine
  engine_version         = local.vars.engine_version
  instance_class         = local.vars.instance_class
  name                   = local.vars.name
  username               = local.vars.username
  password               = local.vars.password
  parameter_group_name   = local.vars.parameter_group_name
  skip_final_snapshot    = local.vars.skip_final_snapshot
  storage_type           = local.vars.storage_type
  vpc_security_group_ids = module.vpc.aws_vpc_id[count.index]
  mysql_rds_az           = local.vars.mysql_rds_az
  db_subnet_group_name   = module.db_subnet_group.aws_db_subnet_group_name
}