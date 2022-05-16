variable "table_name" {}
# variable "hash_key" {}
# variable "hash_key_type" {}
# variable "billing_mode" { default = "PAY_PER_REQUEST" }
variable "handler" {}
variable "runtime" {}
variable "filename" {}
variable "function_name" {}
variable "bucket_name" {}
variable "bucket_acl" {
  default = "private"
}
variable "vpc_id" {
  default = ""
}

variable "vpc_cidr_block" {
  default = ""
}

variable "subnet_ids" {
  default = ""
}

variable "db_name" {
  default = ""  
}

variable "db_enpoint" {
  default = ""
}

variable "username" {
  default = ""
}

variable "password" {
  default = ""
}