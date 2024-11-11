# S3 Bucket for Terraform State Storage
module "terraform_state_s3" {
  source                     = "../../modules/s3"
  bucket_name                = "terraform-state-bucket-${random_string.suffix.result}"
  versioning_enabled         = true
  enable_encryption          = true
  lifecycle_enabled          = true
  transition_to_ia_days      = 30
  transition_to_glacier_days = 90
  expiration_days            = 365
  public_read_access         = false
  tags = {
    Name        = "terraform-state-storage"
    Environment = "bootstrap"
  }
}

# DynamoDB Table for State Locking
resource "aws_dynamodb_table" "terraform_lock" {
  name           = "tflock"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "terraform-lock-table"
    Environment = "bootstrap"
  }
}

# Random string for unique S3 bucket name suffix
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}
