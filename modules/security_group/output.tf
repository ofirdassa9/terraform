data "aws_subnets" "vpc_id" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

data "aws_subnet" "subnet_id" {
  for_each = toset(data.aws_subnets.vpc_id.ids)
  id       = each.value
}

output "subnet_ids" {
  value = [for s in data.aws_subnet.subnet_id : s.id]
}