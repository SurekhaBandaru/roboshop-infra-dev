module "frontend" {
  source         = "git::https://github.com/SurekhaBandaru/terraform-aws-securitygroup.git?ref=main" #"../../terraform-aws-securitygroup"
  project        = var.project
  environment    = var.environment
  sg_name        = var.frontend_sg_name
  sg_description = var.frontend_sg_description
  vpc_id         = local.vpc_id # data.aws_ssm_parameter.vpc_id.value #get from data source, from 00-vpc, it got stored into ssm param, so we used data source to bring till here

}

#Security group for bastion instance  

module "bastion" {
  source         = "git::https://github.com/SurekhaBandaru/terraform-aws-securitygroup.git?ref=main"
  project        = var.project
  environment    = var.environment
  sg_name        = var.bastion_sg_name
  sg_description = var.bastion_sg_description
  vpc_id         = local.vpc_id
}


# add rule for bastion, as admin needs to logon and check/troubleshoot the issue, port no 22 has to be enables
resource "aws_security_group_rule" "bastion_laptop" {
  type              = "ingress" # as admin logins from internet
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] # allow from internet
  security_group_id = module.bastion.sg_id
}

#security group for back end alb
module "backend_alb" {
  source         = "git::https://github.com/SurekhaBandaru/terraform-aws-securitygroup.git?ref=main"
  project        = var.project
  environment    = var.environment
  sg_name        = var.backend_alb_sg_name
  sg_description = var.backend_alb_sg_description
  vpc_id         = local.vpc_id
}

#add rule for backend ALB accepting connections from bastion host on port no 80
resource "aws_security_group_rule" "backend_alb_bastion" {
  type                     = "ingress" # as admin logins from internet
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = module.bastion.sg_id # here, traffic source is bastion, so need to add bastion sg's id here, as we have seen in the class, if one instance to connct with the second, in the second instance's sg, we added first instances sg_id on port 80
  security_group_id        = module.backend_alb.sg_id
}


