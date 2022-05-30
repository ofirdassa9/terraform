output "aws_vpc_id" {
  value = aws_vpc.vpc.id
}

output "aws_vpc_name" {
    value = aws_vpc.vpc
}

output "vpc_cidr_block" {
  value = aws_vpc.vpc.cidr_block
}

output "aws_public_subnet_id" {
    value = aws_subnet.public_subnets.*.id
}

# output "aws_private_subnet_id" {
#     value = aws_subnet.private_subnets.*.id
# }

# output "aws_nat_gateway_id" {
#     value = aws_nat_gateway.nat-gw.*.id
# }

output "aws_internet_gateway_id" {
    value = aws_internet_gateway.igw.id
}

output "sg_mysql_rds" {
  value = aws_security_group.mysql_rds.id
}