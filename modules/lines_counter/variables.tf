variable "table_name" {}
variable "handler" {}
variable "runtime" {}
variable "filename" {}
variable "function_name" {}
variable "lines_bucket_name" {}
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

variable "rtb_id" {
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