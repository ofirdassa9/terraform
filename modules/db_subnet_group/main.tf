resource "aws_db_subnet_group" "mysql_rds_subnet_group" {
  count      = length(var.subnet_ids)
  name       = "net-group-mysql-rds"
  subnet_ids = var.subnet_ids[count.index]

  tags = {
    Name = "net-group-mysql-rds"
  }
}