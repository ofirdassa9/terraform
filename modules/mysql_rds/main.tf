resource "aws_db_subnet_group" "mysql_rds_subnet_group" {
  name       = "db_net_group_mysql_rds"
  subnet_ids = var.subnet_ids
  tags = {
    Name = "db_net_group_mysql_rds"
  }
}

resource "aws_db_instance" "mysql_rds" {
  allocated_storage      = var.allocated_storage
  max_allocated_storage  = var.max_allocated_storage
  engine                 = var.engine
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  db_name                = var.db_name
  username               = var.username
  password               = var.password
  parameter_group_name   = var.parameter_group_name
  skip_final_snapshot    = var.skip_final_snapshot
  storage_type           = var.storage_type
  db_subnet_group_name   = aws_db_subnet_group.mysql_rds_subnet_group.name
  vpc_security_group_ids = var.vpc_security_group_ids
  availability_zone      = var.availability_zone
}