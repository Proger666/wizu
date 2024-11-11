# AWS Config Rule: Ensure S3 buckets have versioning enabled
resource "aws_config_config_rule" "s3_bucket_versioning" {
  name = "s3-bucket-versioning-enabled"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_VERSIONING_ENABLED"
  }
  depends_on = [aws_config_configuration_recorder.main]
}

# AWS Config Rule to detect Public S3 Buckets (Read Access)
resource "aws_config_config_rule" "s3_public_read_prohibited" {
  name = "s3-bucket-public-read-prohibited"
  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
  }
  depends_on = [aws_config_configuration_recorder.main]
}

# AWS Config Rule to detect Public S3 Buckets (Write Access)
resource "aws_config_config_rule" "s3_public_write_prohibited" {
  name = "s3-bucket-public-write-prohibited"
  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_WRITE_PROHIBITED"
  }
  depends_on = [aws_config_configuration_recorder.main]
}

# AWS Config Rule to detect Public EKS Cluster Endpoints
resource "aws_config_config_rule" "eks_endpoint_no_public_access" {
  name = "eks-endpoint-no-public-access"
  source {
    owner             = "AWS"
    source_identifier = "EKS_ENDPOINT_NO_PUBLIC_ACCESS"
  }
  depends_on = [aws_config_configuration_recorder.main]
}

# AWS Config Rule to ensure Administrative Users have MFA enabled
resource "aws_config_config_rule" "iam_user_mfa_enabled" {
  name = "iam-user-mfa-enabled"
  source {
    owner             = "AWS"
    source_identifier = "IAM_USER_MFA_ENABLED"
  }
  depends_on = [aws_config_configuration_recorder.main]
}

# AWS Config Rule to ensure the Root User has MFA enabled
resource "aws_config_config_rule" "root_account_mfa_enabled" {
  name = "root-account-mfa-enabled"
  source {
    owner             = "AWS"
    source_identifier = "ROOT_ACCOUNT_MFA_ENABLED"
  }
  depends_on = [aws_config_configuration_recorder.main]
}

# AWS Config Rule to detect SSH Access Allowed from Public (0.0.0.0/0) IP
resource "aws_config_config_rule" "restricted_ssh" {
  name = "restricted-ssh"
  source {
    owner             = "AWS"
    source_identifier = "INCOMING_SSH_DISABLED"
  }
  depends_on = [aws_config_configuration_recorder.main]
}

# AWS Config Rule to ensure S3 Buckets enforce SSL for encryption in transit
resource "aws_config_config_rule" "s3_bucket_ssl_requests_only" {
  name = "s3-bucket-ssl-requests-only"
  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_SSL_REQUESTS_ONLY"
  }
  depends_on = [aws_config_configuration_recorder.main]
}

# AWS Config Rule to ensure S3 Buckets have Server-Side Encryption enabled for encryption at rest
resource "aws_config_config_rule" "s3_bucket_server_side_encryption_enabled" {
  name = "s3-bucket-server-side-encryption-enabled"
  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"
  }
  depends_on = [aws_config_configuration_recorder.main]
}