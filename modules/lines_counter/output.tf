output "table-name" {
  value = aws_dynamodb_table.table.name
}

output "table-arn" {
  value = aws_dynamodb_table.table.arn
}

data "aws_caller_identity" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}
