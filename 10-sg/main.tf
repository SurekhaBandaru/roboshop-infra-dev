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


#security group for vpn
module "vpn" {
  source         = "git::https://github.com/SurekhaBandaru/terraform-aws-securitygroup.git?ref=main"
  project        = var.project
  environment    = var.environment
  sg_name        = var.vpn_sg_name
  sg_description = var.vpn_sg_description
  vpc_id         = local.vpc_id
}

#we need to allow ssh-22, https-443, 943 and 1194 for vpn from public

resource "aws_security_group_rule" "vpn_ssh" {
  type              = "ingress" # as admin logins from internet
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] # allow from internet
  security_group_id = module.vpn.sg_id
}

resource "aws_security_group_rule" "vpn_https" {
  type              = "ingress" # as admin logins from internet
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] # allow from internet
  security_group_id = module.vpn.sg_id
}

resource "aws_security_group_rule" "vpn_943" {
  type              = "ingress" # as admin logins from internet
  from_port         = 943
  to_port           = 943
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] # allow from internet
  security_group_id = module.vpn.sg_id
}

resource "aws_security_group_rule" "vpn_1194" {
  type              = "ingress" # as admin logins from internet
  from_port         = 1194
  to_port           = 1194
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] # allow from internet
  security_group_id = module.vpn.sg_id
}

#add rule for backend ALB accepting connections from VPN on port no 80
resource "aws_security_group_rule" "backend_vpn" {
  type                     = "ingress" # as admin logins from internet
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"            #http
  source_security_group_id = module.vpn.sg_id # here, traffic source is vpn, so need to add vpn sg's id here, as we have seen in the class, if one instance to connct with the second, in the second instance's sg, we added first instances sg_id on port 80
  security_group_id        = module.backend_alb.sg_id
}

#security group for mongodb
module "mongodb" {
  source         = "git::https://github.com/SurekhaBandaru/terraform-aws-securitygroup.git?ref=main"
  project        = var.project
  environment    = var.environment
  sg_name        = var.mongodb_sg_name
  sg_description = var.mongodb_sg_description
  vpc_id         = local.vpc_id

}


#security group for redis
module "redis" {
  source         = "git::https://github.com/SurekhaBandaru/terraform-aws-securitygroup.git?ref=main"
  project        = var.project
  environment    = var.environment
  sg_name        = var.redis_sg_name
  sg_description = var.redis_sg_description
  vpc_id         = local.vpc_id

}

#security group for mysql
module "mysql" {
  source         = "git::https://github.com/SurekhaBandaru/terraform-aws-securitygroup.git?ref=main"
  project        = var.project
  environment    = var.environment
  sg_name        = var.mysql_sg_name
  sg_description = var.mysql_sg_description
  vpc_id         = local.vpc_id

}

#security group for rabbitMq
module "rabbitmq" {
  source         = "git::https://github.com/SurekhaBandaru/terraform-aws-securitygroup.git?ref=main"
  project        = var.project
  environment    = var.environment
  sg_name        = var.rabbitmq_sg_name
  sg_description = var.rabbitmq_sg_description
  vpc_id         = local.vpc_id

}


#mongodb to allow connections from vpn on port no 22 and 27017 (for testing)
resource "aws_security_group_rule" "mongodb_vpn" {
  count                    = length(var.mongodb_vpn_ports)
  type                     = "ingress"
  from_port                = var.mongodb_vpn_ports[count.index]
  to_port                  = var.mongodb_vpn_ports[count.index]
  protocol                 = "tcp"            #ssh
  source_security_group_id = module.vpn.sg_id # connection coming from vpn
  security_group_id        = module.mongodb.sg_id

}

#redis to allow connections from vpn on port 22, 6379

resource "aws_security_group_rule" "redis_vpn" {
  count                    = length(var.redis_vpn_ports)
  type                     = "ingress"
  from_port                = var.redis_vpn_ports[count.index]
  to_port                  = var.redis_vpn_ports[count.index]
  protocol                 = "tcp"            #ssh
  source_security_group_id = module.vpn.sg_id # connection coming from vpn
  security_group_id        = module.redis.sg_id

}

# mysql to allow connections from vpn on port 22, 3306

resource "aws_security_group_rule" "mysql_vpn" {
  count                    = length(var.mysql_vpn_ports)
  type                     = "ingress"
  from_port                = var.mysql_vpn_ports[count.index]
  to_port                  = var.mysql_vpn_ports[count.index]
  protocol                 = "tcp"            #ssh
  source_security_group_id = module.vpn.sg_id # connection coming from vpn
  security_group_id        = module.mysql.sg_id

}

#rabbitmq to allow connections from vpn to port 22, 5672
resource "aws_security_group_rule" "rabbitmq_vpn" {
  count                    = length(var.rabbitmq_vpn_ports)
  type                     = "ingress"
  from_port                = var.rabbitmq_vpn_ports[count.index]
  to_port                  = var.rabbitmq_vpn_ports[count.index]
  protocol                 = "tcp"            #ssh
  source_security_group_id = module.vpn.sg_id # connection coming from vpn
  security_group_id        = module.rabbitmq.sg_id

}

#security group for catalogue 
module "catalogue" {
  source         = "git::https://github.com/SurekhaBandaru/terraform-aws-securitygroup.git?ref=main"
  project        = var.project
  environment    = var.environment
  sg_name        = var.catalogue_sg_name
  sg_description = var.catalogue_sg_description
  vpc_id         = local.vpc_id
}

# catalogue to allow traffic from backend alb on 8080
resource "aws_security_group_rule" "catalogue_backend_alb" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = module.backend_alb.sg_id
  security_group_id        = module.catalogue.sg_id

}

# catalogue to allow traffic from vpn on 22
resource "aws_security_group_rule" "catalogue_vpn_ssh" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id        = module.catalogue.sg_id
}

# catalogue to allow traffic from vpn on 8080
resource "aws_security_group_rule" "catalogue_vpn_http" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id        = module.catalogue.sg_id
}

# catalogue to allow traffic from bastion on port 22
resource "aws_security_group_rule" "catalogue_bastion" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id        = module.catalogue.sg_id

}

#mongodb to allow connection from catalogue on the port 27017
resource "aws_security_group_rule" "mongodb_catalogue" {
  type                     = "ingress"
  from_port                = 27017
  to_port                  = 27017
  protocol                 = "tcp"
  source_security_group_id = module.catalogue.sg_id
  security_group_id        = module.mongodb.sg_id

}
