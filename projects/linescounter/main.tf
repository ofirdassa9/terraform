locals {
	# vars = jsondecode(file("${path.root}/projects/linescounter/vars.tfvars.json"))
  vars = jsondecode(file("vars.tfvars.json"))
}

provider "aws" {
  profile = local.vars.profile
  region = local.vars.region
}

module "lines_counter" {
  source        = "../../modules/lines_counter"
  hash_key      = local.vars.hash_key
  hash_key_type = local.vars.hash_key_type
  table_name    = local.vars.table_name
  bucket_name   = local.vars.bucket_name
  filename      = local.vars.filename
  function_name = local.vars.function_name
  handler       = local.vars.handler
  runtime       = local.vars.runtime
}