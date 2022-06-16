resource "aws_key_pair" "ec2_key" {
  key_name   = "personal-us-east-1"
  public_key = var.ec2_public_key
}

resource "aws_iam_policy" "ec2_policy" {
  name        = "policy-cloud-watch-logs-metric"
  path        = "/"
  description = "Policy to for ec2 k8s instance"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "AllowReadingMetricsFromCloudWatch",
        "Effect": "Allow",
        "Action": [
          "cloudwatch:DescribeAlarmsForMetric",
          "cloudwatch:DescribeAlarmHistory",
          "cloudwatch:DescribeAlarms",
          "cloudwatch:ListMetrics",
          "cloudwatch:GetMetricData",
          "cloudwatch:GetInsightRuleReport"
        ],
        "Resource": "*"
      },
      {
        "Sid": "AllowReadingLogsFromCloudWatch",
        "Effect": "Allow",
        "Action": [
          "logs:DescribeLogGroups",
          "logs:GetLogGroupFields",
          "logs:StartQuery",
          "logs:StopQuery",
          "logs:GetQueryResults",
          "logs:GetLogEvents"
        ],
        "Resource": "*"
      },
      {
        "Sid": "AllowReadingTagsInstancesRegionsFromEC2",
        "Effect": "Allow",
        "Action": ["ec2:DescribeTags", "ec2:DescribeInstances", "ec2:DescribeRegions"],
        "Resource": "*"
      },
      {
        "Sid": "AllowReadingResourcesForTags",
        "Effect": "Allow",
        "Action": "tag:GetResources",
        "Resource": "*"
      }
    ]
  })
}

resource "aws_security_group" "kind" {
  name        = "sgr-kind"
  description = "Allow kind inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description      = "kind-api"
    from_port        = 7443
    to_port          = 7443
    protocol         = "tcp"
    cidr_blocks      = [var.vpc_cidr_block]
  }

  ingress {
    description      = "grafana"
    from_port        = 80
    to_port          = 80
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
    Name = "sgr-kind"
  }
}

resource "aws_iam_role" "ec2_role" {
  name = "role-ec2-assume-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "role-ec2-assume-role"
  }
}

resource "aws_iam_policy_attachment" "ec2_policy_role_attachment" {
  name       = "ec2_attachment"
  roles      = [aws_iam_role.ec2_role.name]
  policy_arn = aws_iam_policy.ec2_policy.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "profile-i-${var.environment}-cloudwatch-logs-metrics"
  role = aws_iam_role.ec2_role.name
}

module "ec2_instance" {
  source                      = "terraform-aws-modules/ec2-instance/aws"
  version                     = "~> 3.0"
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  name                        = "i-${var.environment}-k8s"
  ami                         = "ami-0c4f7023847b90238"
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.ec2_key.key_name
  monitoring                  = false
  vpc_security_group_ids      = [var.security_group_ids,aws_security_group.kind.id]
  subnet_id                   = var.subnet_id[0]
  associate_public_ip_address = true

  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}