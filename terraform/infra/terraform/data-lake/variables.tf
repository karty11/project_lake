variable "region" { type = string, default = "us-west-2" }
variable "environment" { type = string, default = "dev" }
variable "bucket_name" { type = string, default = "bankapp-datalake-${var.environment}" }
variable "allow_glue" { type = bool, default = false }
