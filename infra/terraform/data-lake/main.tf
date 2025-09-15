provider "aws" {
  region = var.region
}

# S3 bucket
resource "aws_s3_bucket" "datalake" {
  bucket = var.bucket_name

  lifecycle_rule {
    id      = "archive-or-delete"
    enabled = true

    expiration {
      days = 3650 # 10 years
    }

    abort_incomplete_multipart_upload_days = 7
  }

  tags = {
    Environment = var.environment
    Project     = "bankapp"
  }
}

# Enforce Block Public Access
resource "aws_s3_bucket_public_access_block" "datalake_block" {
  bucket = aws_s3_bucket.datalake.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 encryption config
resource "aws_s3_bucket_server_side_encryption_configuration" "datalake_encryption" {
  bucket = aws_s3_bucket.datalake.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_arn
    }
  }
}

# Optional Glue DB
resource "aws_glue_catalog_database" "bankapp_db" {
  count = var.allow_glue ? 1 : 0
  name  = "bankapp_datalake_db_${var.environment}"
}
