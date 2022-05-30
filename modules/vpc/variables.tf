variable "vpc_name" {
default = ""
}

variable "vpc_cidr_block" {
default = ""
}

variable "public_subnets_az" {
  type=list(string)
  default = [ "" ]
}

variable "public_subnets_cidr" {
  type=list(string)
  default = [ "" ]
}

# variable "private_subnets_az" {
#   type=list(string)
#   default = [ "" ]
# }

# variable "private_subnets_cidr" {
#   type=list(string)
#   default = [ "" ]
# }

variable "environment" {
  default = ""
}

variable "enable_dns_support" {
  type = bool
}

variable "enable_dns_hostnames" {
  type = bool
}

variable "vpc_id" {
  default = ""
}