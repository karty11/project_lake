
data "aws_caller_identity" "current" {}

resource "aws_glue_catalog_database" "datalake_db" {
  name = "datalake_db"
}
resource "aws_iam_policy" "glue_extra_policy" {
  name        = "glue-extra-policy"
  description = "Extra permissions for Glue job"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:bankapp/mysql*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.datalake_bucket}",
          "arn:aws:s3:::${var.datalake_bucket}/*"
        ]
      }
    ]
  })
}

############################################
# Glue Job to export MySQL data to S3
############################################

resource "aws_glue_job" "mysql_to_s3" {
  name     = "mysql-to-s3"
  role_arn = var.glue_role_arn

  command {
    name            = "glueetl"
    python_version  = "3"
    script_location = "s3://${var.datalake_bucket}/scripts/mysql_to_s3.py"
  }

  default_arguments = {
    "--TempDir"             = "s3://${var.datalake_bucket}/tmp/"
    "--output_path"         = "s3://${var.datalake_bucket}/bankapp/transactions/"
    "--job-bookmark-option" = "job-bookmark-enable"
  }

  glue_version = "3.0"
  number_of_workers = 2
  worker_type       = "G.1X"
}

############################################
# Glue crawler for exported data
############################################

resource "aws_glue_crawler" "mysql_export_crawler" {
  name         = "mysql-export-crawler"
  role         = var.glue_role_arn
  database_name = aws_glue_catalog_database.datalake_db.name

  s3_target {
    path = "s3://${var.datalake_bucket}/bankapp/transactions/"
  }

  schedule = "cron(0 * * * ? *)" # every hour
}




############################################
# Data lookups for existing infra
############################################

data "aws_security_group" "glue_sg" {
  filter {
    name   = "group-name"
    values = ["project-node-sg"] # change to your SG name
  }
  vpc_id = var.vpc_id
}

data "aws_subnet" "private_subnet1" {
  filter {
    name   = "tag:Name"
    values = ["project-subnet-1"] # change to your subnet tag
  }
}


