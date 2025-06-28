resource "aws_ssm_parameter" "vpc_id" { # just to say store vpc_id into ssm parameter store
  name  = "/${var.project}/${var.environment}/vpc_id"
  type  = "String"
  value = module.vpc.vpc_id
}

resource "aws_ssm_parameter" "public_subnet_ids" {
  name  = "/${var.project}/${var.environment}/public_subnet_ids"
  type  = "StringList"
  value = join(",", module.vpc.public_subnet_ids) # actual output is subnet_ids = ["subnet-03e66aa42c25e64b0","subnet-0f63932fdec4c0bde",] but aws accepts StringList as just comma separated values, so we used and join and got subnet-03e66aa42c25e64b0,subnet-0f63932fdec4c0bde which is accepted by AWS

}

resource "aws_ssm_parameter" "private_subnet_ids" {
  name  = "/${var.project}/${var.environment}/private_subnet_ids"
  type  = "StringList"
  value = join(",", module.vpc.private_subnet_ids)
}

resource "aws_ssm_parameter" "database_subnet_ids" {
  name  = "/${var.project}/${var.environment}/database_subnet_ids"
  type  = "StringList"
  value = join(",", module.vpc.database_subnet_ids)
}