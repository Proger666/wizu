# IAM role for AWS Config
resource "aws_iam_role" "config_role" {
  name               = "${var.name_prefix}-${var.environment}-config-role"
  assume_role_policy = data.aws_iam_policy_document.config_assume_role_policy.json

  tags = {
    Name = "${var.name_prefix}-${var.environment}-config-role"
    Team = var.team
    Env  = var.environment
  }
}

data "aws_iam_policy_document" "config_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
  }
}

# Attach AWS Config managed policy for necessary permissions
resource "aws_iam_role_policy_attachment" "config_policy_attachment" {
  role       = aws_iam_role.config_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

# AWS Config Configuration Recorder
resource "aws_config_configuration_recorder" "main" {
  name     = "${var.name_prefix}-${var.environment}-config-recorder"
  role_arn = aws_iam_role.config_role.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

# AWS Config Delivery Channel to send configuration changes to the S3 bucket
resource "aws_config_delivery_channel" "main" {
  name           = "${var.name_prefix}-${var.environment}-config-delivery-channel"
  s3_bucket_name = var.aws_config_bucket_name
  depends_on     = [aws_config_configuration_recorder.main]
}

# Enable the configuration recorder
resource "aws_config_configuration_recorder_status" "main" {
  name       = aws_config_configuration_recorder.main.name
  is_enabled = true
}

resource "aws_s3_bucket_policy" "config_bucket_policy" {
  bucket = var.aws_config_bucket_name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AWSConfigPermissions",
        Effect = "Allow",
        Principal = {
          Service = "config.amazonaws.com"
        },
        Action = [
          "s3:PutObject",
          "s3:GetBucketAcl",
          "s3:GetBucketLocation"
        ],
        Resource = [
          "${var.aws_config_bucket_arn}",
          "${var.aws_config_bucket_arn}/*"
        ]
      }
    ]
  })
}

