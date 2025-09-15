provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "datalake" {
  bucket = var.bucket_name
  acl    = "private"

  versioning { enabled = true }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule {
    id      = "archive-or-delete"
    enabled = true
    expiration { days = 3650 } # 10 years
    abort_incomplete_multipart_upload_days = 7
  }

  tags = {
    Environment = var.environment
    Project     = "bankapp"
  }
}

# Optional Glue DB
resource "aws_glue_catalog_database" "bankapp_db" {
  count = var.allow_glue ? 1 : 0
  name  = "bankapp_datalake_db_${var.environment}"
}
