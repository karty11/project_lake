resource "aws_glue_job" "mysql_to_s3" {
  name     = "mysql-to-s3-export"
  role_arn = aws_iam_role.glue_role.arn

  command {
    name            = "glueetl"
    python_version  = "3"
    script_location = "s3://${var.datalake_bucket}/scripts/mysql_to_s3.py"
  }

  default_arguments = {
    "--TempDir"               = "s3://${var.datalake_bucket}/tmp/"
    "--job-bookmark-option"   = "job-bookmark-enable"
    "--connection_name"       = aws_glue_connection.mysql_connection.name
    "--secret_name"           = "bankapp/mysql"
    "--output_path"           = "s3://${var.datalake_bucket}/bankapp/transactions/"
  }

  glue_version = "4.0"
  max_capacity = 2
}

resource "aws_glue_crawler" "mysql_export_crawler" {
  name         = "mysql-to-s3-crawler"
  role         = aws_iam_role.glue_role.arn
  database_name = aws_glue_catalog_database.datalake_db.name

  s3_target {
    path = "s3://${var.datalake_bucket}/bankapp/transactions/"
  }

  schedule = "cron(0 * * * ? *)" # run hourly
}

