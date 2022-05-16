resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.bucket.id
  acl    = var.bucket_acl
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_security_group" "mysql_rds_for_linescounter" {
  name        = "sg_mysql_rds_lines_counter"
  description = "Allow MySQL-RDS inbound traffic"
  vpc_id      = var.vpc_id

  egress {
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = [var.vpc_cidr_block]
  }

  tags = {
    Name = "mysql_rds_for_linescounter"
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_${var.function_name}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "allow_s3_read" {
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "BucketAccess",
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": [
        "${aws_s3_bucket.bucket.arn}"
      ]
    },
    {
      "Sid": "BucketContentsAccess",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": [
        "${aws_s3_bucket.bucket.arn}/*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "AWSLambdaVPCAccessExecutionRole" {
    role       = aws_iam_role.iam_for_lambda.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy_attachment" "allow_s3_read" {
    role       = aws_iam_role.iam_for_lambda.name
    policy_arn = aws_iam_policy.allow_s3_read.arn
}


resource "aws_lambda_function" "function" {
  function_name = var.function_name
  handler       = var.handler
  role          = aws_iam_role.iam_for_lambda.arn
  runtime       = var.runtime
  filename      = var.filename
  layers        = [aws_lambda_layer_version.lambda_layer.arn]
  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.mysql_rds_for_linescounter.id]
  }
  environment {
    variables = {
      USERNAME    = var.username
      PASSWORD    = var.password
      DB_ENDPOINT = var.db_enpoint
      DB_NAME     = var.db_name
      TABLE_NAME  = var.table_name
    }
  }
}

resource "aws_lambda_layer_version" "lambda_layer" {
  filename   = "${path.module}/layers/pymysql_layer.zip"
  layer_name = "layer_linescounter"

  compatible_runtimes = [var.runtime]
}

resource "aws_lambda_permission" "allow_bucket_lambda" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.bucket.arn
}

resource "aws_s3_bucket_notification" "allow_s3_bucket_notification" {
  bucket = aws_s3_bucket.bucket.bucket

  lambda_function {
    lambda_function_arn = aws_lambda_function.function.arn
    events              = ["s3:ObjectCreated:*"]
  }
}