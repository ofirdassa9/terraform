resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  tags = {
    "Name" = "vpc-${var.environment}"
  }
}

resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnets_az)
  cidr_block              = var.public_subnets_cidr[count.index]
  availability_zone       = var.public_subnets_az[count.index]
  vpc_id                  = aws_vpc.vpc.id
  tags = {
    "Name" = "net-public-${var.environment}-${format("%02d", count.index + 1)}"
  }
}

# resource "aws_subnet" "private_subnets" {
#   count             = length(var.private_subnets_az)
#   cidr_block        = var.private_subnets_cidr[count.index]
#   availability_zone = var.private_subnets_az[count.index]
#   vpc_id            = aws_vpc.vpc.id
#   tags = {
#     "Name" = "net-private-${var.environment}-${format("%02d", count.index + 1)}"
#   }
# }

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
      "Name" = "igw-${var.environment}"
  }
}

resource "aws_route_table" "rtb_public" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags   = {
    Name = "rtb_public"
  }
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnets_az)

  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.rtb_public.id
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id             = aws_vpc.vpc.id
  service_name       = "com.amazonaws.us-east-1.s3"
  tags = {
    Name = "S3-endpoint"
  }
}

resource "aws_vpc_endpoint_route_table_association" "s3" {
  route_table_id  = aws_route_table.rtb_public.id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}

# resource "aws_nat_gateway" "nat-gw" {
#   count             = length(var.private_subnets_az)
#   connectivity_type = "private"
#   subnet_id         = aws_subnet.private_subnets[count.index].id
#   tags = {
#     Name = "NAT-GW--${format("%02d", count.index + 1)}"
#   }
# }

# resource "aws_route_table" "rtb_private" {
#   vpc_id    = aws_vpc.vpc.id
#   route {
#     cidr_block     = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.nat-gw[0].id
#   }
#   tags   = {
#     Name = "rtb_private"
#   }
# }

resource "aws_security_group" "mysql_rds" {
  name        = "sgr-mysql-rds"
  description = "Allow MySQL-RDS inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "MYSQL"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.vpc.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sgr-mysql-rds"
  }
}

resource "aws_security_group" "vpc_access" {
  name        = "sgr-vpc-access"
  description = "SSH & RDP from home and office"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "RDP"
    from_port        = 3389
    to_port          = 3389
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
    Name = "sgr-vpc-access"
  }
}