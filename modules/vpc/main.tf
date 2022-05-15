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