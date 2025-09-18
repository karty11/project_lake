#############################
# IAM Role for Glue Job
#############################
resource "aws_iam_role" "glue_role" {
  name = "bankapp-glue-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "glue.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "glue_policy_attach" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

# Allow Glue to access Secrets Manager + S3 bucket
resource "aws_iam_policy" "glue_extra_policy" {
  name        = "bankapp-glue-extra-policy"
  description = "Allow Glue Job to access S3 datalake bucket + Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "secretsmanager:GetSecretValue"
        ],
        Resource = "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:bankapp/mysql*"
      },
      {
        Effect   = "Allow",
        Action   = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.datalake_bucket.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.datalake_bucket.bucket}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "glue_extra_policy_attach" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_extra_policy.arn
}

#############################
# Glue Job (MySQL → S3 export)
#############################
resource "aws_glue_job" "mysql_to_s3" {
  name     = "mysql-to-s3-export"
  role_arn = aws_iam_role.glue_role.arn

  command {
    name            = "glueetl"
    python_version  = "3"
    script_location = "s3://${aws_s3_bucket.datalake_bucket.bucket}/scripts/mysql_to_s3.py"
  }

  default_arguments = {
    "--TempDir"             = "s3://${aws_s3_bucket.datalake_bucket.bucket}/tmp/"
    "--job-bookmark-option" = "job-bookmark-enable"
    "--secret_name"         = "bankapp/mysql"
    "--output_path"         = "s3://${aws_s3_bucket.datalake_bucket.bucket}/bankapp/transactions/"
  }

  glue_version = "4.0"
  max_capacity = 2
}

#############################
# Glue Crawler
#############################
resource "aws_glue_crawler" "mysql_export_crawler" {
  name          = "mysql-to-s3-crawler"
  role          = aws_iam_role.glue_role.arn
  database_name = aws_glue_catalog_database.datalake_db.name

  s3_target {
    path = "s3://${aws_s3_bucket.datalake_bucket.bucket}/bankapp/transactions/"
  }

  schedule = "cron(0 * * * ? *)" # run hourly
}

