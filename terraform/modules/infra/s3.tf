module "backup_bucket" {
  source                     = "../s3"
  bucket_name                = "${var.name_prefix}-${var.environment}-backup-bucket"
  versioning_enabled         = true
  lifecycle_enabled          = true
  transition_to_ia_days      = 30
  transition_to_glacier_days = 90
  expiration_days            = 365
  enable_encryption          = true
  public_read_access         = true
  tags                       = { Name = "${var.name_prefix}-backup" }
}

module "findings_bucket" {
  source                = "../s3"
  bucket_name           = "${var.name_prefix}-${var.environment}-findings-bucket"
  versioning_enabled    = true
  enable_encryption     = true
  lifecycle_enabled     = true
  transition_to_ia_days = 90
  expiration_days       = 180
  tags                  = { Name = "${var.name_prefix}-findings" }
}