# IAM Role for EC2 Instance to Access S3 for Backups and EC2 Access
resource "aws_iam_role" "db_instance_role" {
  name               = "${var.environment}-${var.database_hostname}-db-instance-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role_policy.json

  tags = {
    Name = "${var.environment}-${var.database_hostname}-db-instance-role"
  }
}

# IAM Policy Document for EC2 Assume Role Policy
data "aws_iam_policy_document" "ec2_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_caller_identity" "current" {}

# IAM Policy to Grant EC2 Access to Backup S3 Bucket and EC2 Permissions
data "aws_iam_policy_document" "db_instance_policy" {
  statement {
    effect  = "Allow"
    actions = ["s3:PutObject", "s3:GetObject", "s3:ListBucket"]
    resources = [
      "${module.backup_bucket.bucket_arn}/*",
      module.backup_bucket.bucket_arn
    ]
  }

  # Secrets Manager Access for Database Credentials
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      "arn:aws:secretsmanager:${var.installation_region}:${data.aws_caller_identity.current.account_id}:secret:prod/db_credentials*"
    ]
  }

  statement {
    effect    = "Allow"
    actions   = ["ec2:*"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "db_instance_s3_policy" {
  name   = "${var.environment}-${var.database_hostname}-s3-access-policy"
  role   = aws_iam_role.db_instance_role.id
  policy = data.aws_iam_policy_document.db_instance_policy.json


}

# IAM Instance Profile for EC2 Instance
resource "aws_iam_instance_profile" "db_instance_profile" {
  name = "${var.environment}-${var.database_hostname}-instance-profile"
  role = aws_iam_role.db_instance_role.name

  tags = {
    Name = "${var.environment}-${var.database_hostname}-instance-profile"
  }
}

# IAM Policy for Web Application
data "aws_iam_policy_document" "web_app_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      "${module.backup_bucket.bucket_arn}/*",
      module.backup_bucket.bucket_arn
    ]
  }
}

resource "aws_iam_policy" "web_app_policy" {
  name        = "${var.name_prefix}-${var.environment}-${var.database_hostname}-web-app-policy"
  description = "Policy for web application to access S3 backups"
  policy      = data.aws_iam_policy_document.web_app_policy.json

  tags = {
    Name = "${var.name_prefix}-${var.environment}-${var.database_hostname}-web-app-policy"
  }
}

#creates initial IAM role for cluster access
module "allow_eks_access_iam_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.3.1"

  name          = "allow-eks-access"
  create_policy = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "eks:DescribeCluster",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
