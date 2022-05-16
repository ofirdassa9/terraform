variable "db_subnet_group_name" {
  default = ""
}

variable "security_group_ids" {
  type=list(string)
  default = [ "" ]
}

variable "mysql_rds_az" {
    default = ""
}

variable "allocated_storage" {
  type = number
}

variable "max_allocated_storage" {
  type = number
}

variable "engine" {
  default = ""
}

variable "engine_version" {
  default = ""
}

variable "instance_class" {
  default = ""
}

variable "name" {
  default = ""
}

variable "username" {
  default = ""
}

variable "password" {
  default = ""
}

variable "parameter_group_name" {
  default = ""
}

variable "skip_final_snapshot" {
  type = bool
}

variable "storage_type" {
  default = ""
}

variable "vpc_security_group_ids" {
  type=list(string)
  default = [ "" ]
}