variable "region" { type = string, default = "ap-south-1" }
variable "environment" { type = string, default = "dev" }
variable "bucket_name" { type = string, default = "bankapp-datalake-${var.environment}" }
