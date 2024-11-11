# modules/s3/main.tf

resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name

  versioning {
    enabled = var.versioning_enabled
  }

  # Server-side encryption
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = var.sse_algorithm
        kms_master_key_id = var.enable_encryption ? var.kms_master_key_id : null
      }
    }
  }

  # Lifecycle policy
  lifecycle_rule {
    id      = var.lifecycle_id
    enabled = var.lifecycle_enabled

    transition {
      days          = var.transition_to_ia_days
      storage_class = var.ia_storage_class
    }

    # Conditional Glacier transition
    dynamic "transition" {
      for_each = var.transition_to_glacier_days > 0 ? [var.transition_to_glacier_days] : []
      content {
        days          = transition.value
        storage_class = var.glacier_storage_class
      }
    }

    expiration {
      days = var.expiration_days
    }
  }

  tags = var.tags
}

# Separate resource for blocking public access
resource "aws_s3_bucket_public_access_block" "this_public_access_block" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = var.block_public_acls
  ignore_public_acls      = var.ignore_public_acls
  block_public_policy     = var.public_read_access ? false : var.block_public_policy
  restrict_public_buckets = var.public_read_access ? false : var.restrict_public_buckets
}

# S3 Bucket Policy for public read access if enabled
resource "aws_s3_bucket_policy" "public_read" {
  count = var.public_read_access ? 1 : 0

  bucket = aws_s3_bucket.this.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.this.arn}/*"
      }
    ]
  })
}