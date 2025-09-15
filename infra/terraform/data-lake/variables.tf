variable "region" { 
  type = string
  default = "us-west-2" 
}
variable "environment" { 
  type = string 
  default = "dev" 
}
variable "bucket_name" { 
  type = string
  default = ""
}
variable "glue_db" {
  type    = string
  default = ""
}
variable "allow_glue" {
  type    = bool
  default = true
  description = "Set to true to create AWS Glue catalog database, false to skip."
}
