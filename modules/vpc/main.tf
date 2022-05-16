resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_support = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  tags = {
    "Name" = "vpc-${var.environment}"
  }
}

resource "aws_subnet" "public_subnets" {
  count             = length(var.public_subnets_az)
  cidr_block        = var.public_subnets_cidr[count.index]
  availability_zone = var.public_subnets_az[count.index]
  vpc_id            = aws_vpc.vpc.id
  tags = {
    "Name" = "net-public-${var.environment}-0${count.index+1}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
      "Name" = "igw-${var.environment}"
  }
}

resource "aws_route_table" "rtb_public" {
  vpc_id     = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags   = {
    Name       = "rtb_public"
  }
}

# resource "aws_route" "public_routes" {
#   for_each                  = toset(var.public_subnets_cidr)
#   route_table_id            = aws_route_table.rtb_public.id
#   destination_cidr_block    = each.key
#   gateway_id                = aws_internet_gateway.igw.id
#   depends_on                = [aws_route_table.rtb_public]
# }

resource "aws_security_group" "mysql_rds" {
  name        = "sg_mysql_rds"
  description = "Allow MySQL-RDS inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "MYSQL"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.vpc.cidr_block]
  }

    ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.vpc_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mysql_rds"
  }
}