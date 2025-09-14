output "bucket_name" { value = aws_s3_bucket.datalake.bucket }
output "s3_arn" { value = aws_s3_bucket.datalake.arn }
output "glue_db" { value = aws_glue_catalog_database.bankapp_db.name }
