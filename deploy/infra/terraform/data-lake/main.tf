provider "aws" {
region = var.region
}

resource "aws_s3_bucket" "datalake" {
bucket = var.bucket_name
acl = "private"
versioning {
enabled = true
}
lifecycle_rule {
id = "retain-raw"
enabled = true
expiration { days = 3650 }
abort_incomplete_multipart_upload_days = 7
}
server_side_encryption_configuration {
rule {
apply_server_side_encryption_by_default {
sse_algorithm = "AES256"
}
}
}
tags = {
Environment = var.environment
Project = "bankapp"
}
}
# IAM policy for app to Put/Get/List
data "aws_iam_policy_document" "app_s3_access" {
statement {
actions = [
"s3:PutObject",
"s3:PutObjectAcl",
"s3:GetObject",
"s3:ListBucket"
]
resources = [
aws_s3_bucket.datalake.arn,
"${aws_s3_bucket.datalake.arn}/*"
]
effect = "Allow"
}
}


resource "aws_iam_policy" "bankapp_s3_policy" {
name = "bankapp-datalake-s3-policy-${var.environment}"
policy = data.aws_iam_policy_document.app_s3_access.json
}


# Optional IAM role (non-IRSA example) - adjust for IRSA
resource "aws_iam_role" "bankapp_role" {
name = "bankapp-role-${var.environment}"
assume_role_policy = jsonencode({
"Version": "2012-10-17",
"Statement": [{
"Action": "sts:AssumeRole",
"Principal": {"Service": "ec2.amazonaws.com"},
"Effect": "Allow",
"Sid": ""
}]
})
}


resource "aws_iam_role_policy_attachment" "attach" {
role = aws_iam_role.bankapp_role.name
policy_arn = aws_iam_policy.bankapp_s3_policy.arn
}


resource "aws_glue_catalog_database" "bankapp_db" {
name = "bankapp_datalake_db_${var.environment}"
}
