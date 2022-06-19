locals {
	vars = jsondecode(file("${path.cwd}/modules/vars.tfvars.json"))
}

provider "aws" {
  profile = local.vars.profile
  region = local.vars.region
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}


module "vpc" {
  source               = "./modules/vpc"
  vpc_name             = local.vars.vpc_name
  vpc_cidr_block       = local.vars.vpc_cidr_block
  public_subnets_az    = local.vars.public_subnets_az
  public_subnets_cidr  = local.vars.public_subnets_cidr
  # private_subnets_az   = local.vars.private_subnets_az
  # private_subnets_cidr = local.vars.private_subnets_cidr
  # home_cidr            = local.vars.home_cidr
  # office_cidr          = local.vars.office_cidr
  environment          = local.vars.environment
  enable_dns_support   = local.vars.enable_dns_support
  enable_dns_hostnames = local.vars.enable_dns_hostnames
}

module "mysql_rds" {
  source                 = "./modules/mysql_rds"
  subnet_ids             = module.vpc.aws_public_subnet_id
  allocated_storage      = local.vars.allocated_storage
  max_allocated_storage  = local.vars.max_allocated_storage
  engine                 = local.vars.engine
  engine_version         = local.vars.engine_version
  instance_class         = local.vars.instance_class
  db_name                = local.vars.db_name
  username               = local.vars.username
  password               = local.vars.password
  parameter_group_name   = local.vars.parameter_group_name
  skip_final_snapshot    = local.vars.skip_final_snapshot
  storage_type           = local.vars.storage_type
  vpc_security_group_ids = [module.vpc.sg_mysql_rds]
  availability_zone      = local.vars.mysql_rds_az
}

module "lines_counter" {
  depends_on = [
    module.mysql_rds
  ]
  source               = "./modules/lines_counter"
  vpc_id               = module.vpc.aws_vpc_id
  vpc_cidr_block       = module.vpc.vpc_cidr_block
  subnet_ids           = module.vpc.aws_public_subnet_id
  username             = local.vars.username
  password             = local.vars.password
  db_enpoint           = module.mysql_rds.address
  db_name              = module.mysql_rds.db_name
  table_name           = local.vars.table_name
  lines_bucket_name    = local.vars.lines_bucket_name
  filename             = local.vars.filename
  function_name        = local.vars.function_name
  handler              = local.vars.handler
  runtime              = local.vars.runtime
}

module "ec2_k8s" {
  source             = "./modules/kind"
  vpc_id             = module.vpc.aws_vpc_id
  vpc_cidr_block     = module.vpc.vpc_cidr_block
  ec2_public_key     = local.vars.ec2_public_key
  environment        = local.vars.environment
  security_group_ids = module.vpc.sg_vpc_access
  subnet_id          = module.vpc.aws_public_subnet_id
  az_for_ebs         = local.vars.public_subnets_az
}

module "words_counter_batch" {
  source                = "./modules/words_counter_batch"
  AWS_ACCESS_KEY_ID     = local.vars.AWS_ACCESS_KEY_ID
  AWS_SECRET_ACCESS_KEY = local.vars.AWS_SECRET_ACCESS_KEY
  DB_ENDPOINT           = module.mysql_rds.address
  USERNAME              = local.vars.username
  PASSWORD              = local.vars.password
  DB_NAME               = module.mysql_rds.db_name
  BUCKET_NAME           = local.vars.words_bucket_name
  TABLE_NAME            = local.vars.words_table_name

}