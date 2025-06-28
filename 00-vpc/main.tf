module "vpc" {
  source                = "git::https://github.com/SurekhaBandaru/terraform-aws-vpc.git?ref=main"
  project               = var.project
  environment           = var.environment
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  database_subnet_cidrs = var.database_subnet_cidrs
  is_peering_required   = true #enable peering between two vpcs
}

#added for testing puropse
/* output "vpc_id" {
  value = module.vpc.vpc_id #here module.vpc is mentioned above and it is declared as vpc_id is terraform vpc module 
} */
