
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

#security group for catalogue 
module "catalogue" {
  source         = "git::https://github.com/SurekhaBandaru/terraform-aws-securitygroup.git?ref=main"
  project        = var.project
  environment    = var.environment
  sg_name        = var.catalogue_sg_name
  sg_description = var.catalogue_sg_description
  vpc_id         = local.vpc_id
}

#user security group
module "user" {
  source         = "git::https://github.com/SurekhaBandaru/terraform-aws-securitygroup.git?ref=main"
  project        = var.project
  environment    = var.environment
  sg_name        = var.user_sg_name
  sg_description = var.user_sg_description
  vpc_id         = local.vpc_id
}

#cart security group
module "cart" {
  source         = "git::https://github.com/SurekhaBandaru/terraform-aws-securitygroup.git?ref=main"
  project        = var.project
  environment    = var.environment
  sg_name        = var.cart_sg_name
  sg_description = var.cart_sg_description
  vpc_id         = local.vpc_id
}

#shipping security group
module "shipping" {
  source         = "git::https://github.com/SurekhaBandaru/terraform-aws-securitygroup.git?ref=main"
  project        = var.project
  environment    = var.environment
  sg_name        = var.shipping_sg_name
  sg_description = var.shipping_sg_description
  vpc_id         = local.vpc_id
}

#payment security group
module "payment" {
  source         = "git::https://github.com/SurekhaBandaru/terraform-aws-securitygroup.git?ref=main"
  project        = var.project
  environment    = var.environment
  sg_name        = var.payment_sg_name
  sg_description = var.payment_sg_description
  vpc_id         = local.vpc_id
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

module "frontend" {
  source         = "git::https://github.com/SurekhaBandaru/terraform-aws-securitygroup.git?ref=main" #"../../terraform-aws-securitygroup"
  project        = var.project
  environment    = var.environment
  sg_name        = var.frontend_sg_name
  sg_description = var.frontend_sg_description
  vpc_id         = local.vpc_id # data.aws_ssm_parameter.vpc_id.value #get from data source, from 00-vpc, it got stored into ssm param, so we used data source to bring till here

}

module "frontend_alb" {
  source         = "git::https://github.com/SurekhaBandaru/terraform-aws-securitygroup.git?ref=main"
  project        = var.project
  environment    = var.environment
  sg_name        = var.frontend_alb_sg_name
  sg_description = var.frontend_sg_description
  vpc_id         = local.vpc_id
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


#security group for vpn
module "vpn" {
  source         = "git::https://github.com/SurekhaBandaru/terraform-aws-securitygroup.git?ref=main"
  project        = var.project
  environment    = var.environment
  sg_name        = var.vpn_sg_name
  sg_description = var.vpn_sg_description
  vpc_id         = local.vpc_id
}

# add rule for bastion, as admin needs to logon and check/troubleshoot the issue, port no 22 has to be enabled
resource "aws_security_group_rule" "bastion_laptop" {
  type              = "ingress" # as admin logins from internet
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] # allow from internet
  security_group_id = module.bastion.sg_id
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
resource "aws_security_group_rule" "backend_alb_vpn" {
  type                     = "ingress" # as admin logins from internet
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"            #http
  source_security_group_id = module.vpn.sg_id # here, traffic source is vpn, so need to add vpn sg's id here, as we have seen in the class, if one instance to connct with the second, in the second instance's sg, we added first instances sg_id on port 80
  security_group_id        = module.backend_alb.sg_id
}


#mongodb to allow connections from vpn on port no 22 and 27017 (for testing)
resource "aws_security_group_rule" "mongodb_vpn" {
  count                    = length(var.mongodb_ports)
  type                     = "ingress"
  from_port                = var.mongodb_ports[count.index]
  to_port                  = var.mongodb_ports[count.index]
  protocol                 = "tcp"            #ssh
  source_security_group_id = module.vpn.sg_id # connection coming from vpn
  security_group_id        = module.mongodb.sg_id

}

#mongodb to allow connections from bastion on port 22 and 27017
resource "aws_security_group_rule" "mongodb_bastion" {
  count                    = length(var.mongodb_ports)
  type                     = "ingress"
  from_port                = var.mongodb_ports[count.index]
  to_port                  = var.mongodb_ports[count.index]
  protocol                 = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id        = module.mongodb.sg_id
}


#redis to allow connections from vpn on port 22, 6379

resource "aws_security_group_rule" "redis_vpn" {
  count                    = length(var.redis_ports)
  type                     = "ingress"
  from_port                = var.redis_ports[count.index]
  to_port                  = var.redis_ports[count.index]
  protocol                 = "tcp"            #ssh
  source_security_group_id = module.vpn.sg_id # connection coming from vpn
  security_group_id        = module.redis.sg_id

}

#redis to allow connections from bastion on 22, 6379
resource "aws_security_group_rule" "redis_bastion" {
  count                    = length(var.redis_ports)
  type                     = "ingress"
  from_port                = var.redis_ports[count.index]
  to_port                  = var.redis_ports[count.index]
  protocol                 = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id        = module.redis.sg_id
}

#redis to allow connections from user on port 6379
resource "aws_security_group_rule" "redis_user" {
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  source_security_group_id = module.user.sg_id
  security_group_id        = module.redis.sg_id
}

#redis to allow connections from cart on port 6379
resource "aws_security_group_rule" "redis_cart" {
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  source_security_group_id = module.cart.sg_id
  security_group_id        = module.redis.sg_id
}

# mysql to allow connections from vpn on port 22, 3306

resource "aws_security_group_rule" "mysql_vpn" {
  count                    = length(var.mysql_ports)
  type                     = "ingress"
  from_port                = var.mysql_ports[count.index]
  to_port                  = var.mysql_ports[count.index]
  protocol                 = "tcp"            #ssh
  source_security_group_id = module.vpn.sg_id # connection coming from vpn
  security_group_id        = module.mysql.sg_id

}

#mysql to allow connections from bastion on 22, 3306
resource "aws_security_group_rule" "mysql_bastion" {
  count                    = length(var.mysql_ports)
  type                     = "ingress"
  from_port                = var.mysql_ports[count.index]
  to_port                  = var.mysql_ports[count.index]
  protocol                 = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id        = module.mysql.sg_id
}

#mysql to allow connections from shipping on 3306 

resource "aws_security_group_rule" "mysql_shiping" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = module.shipping.sg_id
  security_group_id        = module.mysql.sg_id
}

#rabbitmq to allow connections from vpn to port 22, 5672
resource "aws_security_group_rule" "rabbitmq_vpn" {
  count                    = length(var.rabbitmq_ports)
  type                     = "ingress"
  from_port                = var.rabbitmq_ports[count.index]
  to_port                  = var.rabbitmq_ports[count.index]
  protocol                 = "tcp"            #ssh
  source_security_group_id = module.vpn.sg_id # connection coming from vpn
  security_group_id        = module.rabbitmq.sg_id

}

#rabbitmq to allow connections from bastion on port 22, 5672

resource "aws_security_group_rule" "rabbitmq_bastion" {
  count                    = length(var.rabbitmq_ports)
  type                     = "ingress"
  from_port                = var.rabbitmq_ports[count.index]
  to_port                  = var.rabbitmq_ports[count.index]
  protocol                 = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id        = module.rabbitmq.sg_id
}

#rabbitmq to allow connections from payment on port 5672

resource "aws_security_group_rule" "rabbitmq_payment" {
  type                     = "ingress"
  from_port                = 5672
  to_port                  = 5672
  protocol                 = "tcp"
  source_security_group_id = module.payment.sg_id
  security_group_id        = module.rabbitmq.sg_id
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

# catalogue to allow traffic from bastion on port 22 ssh, 8080 http
resource "aws_security_group_rule" "catalogue_bastion" {
  count                    = length(var.bastion_ports)
  type                     = "ingress"
  from_port                = var.bastion_ports[count.index]
  to_port                  = var.bastion_ports[count.index]
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

# catalogue to allow traffic from backend alb on 8080
resource "aws_security_group_rule" "catalogue_backend_alb" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = module.backend_alb.sg_id
  security_group_id        = module.catalogue.sg_id

}

#mongodb to accept connection from user on port 27017
resource "aws_security_group_rule" "mongodb_user" {
  type                     = "ingress"
  from_port                = 2017
  to_port                  = 27017
  protocol                 = "tcp"
  source_security_group_id = module.user.sg_id
  security_group_id        = module.mongodb.sg_id

}


#security group rules for user

#user to allow 22, 8080 from vpn
resource "aws_security_group_rule" "user_vpn" {
  count                    = length(var.vpn_ports)
  type                     = "ingress"
  from_port                = var.vpn_ports[count.index]
  to_port                  = var.vpn_ports[count.index]
  protocol                 = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id        = module.user.sg_id
}

#user to allow 22 from bastion
resource "aws_security_group_rule" "user_bastion" {
  count                    = length(var.bastion_ports)
  type                     = "ingress"
  from_port                = var.bastion_ports[count.index]
  to_port                  = var.bastion_ports[count.index]
  protocol                 = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id        = module.user.sg_id


}

#user to allow 8080 from application load balancer
resource "aws_security_group_rule" "user_backend_alb" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = module.backend_alb.sg_id
  security_group_id        = module.user.sg_id

}


#security group rule for cart
#cart to allow 22, 8080 from vpn
resource "aws_security_group_rule" "cart_vpn" {
  count                    = length(var.vpn_ports)
  type                     = "ingress"
  from_port                = var.vpn_ports[count.index]
  to_port                  = var.vpn_ports[count.index]
  protocol                 = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id        = module.cart.sg_id
}

#cart to allow 22,8080 from bastion # same like vpn
resource "aws_security_group_rule" "cart_bastion" {
  count                    = length(var.bastion_ports)
  type                     = "ingress"
  from_port                = var.bastion_ports[count.index]
  to_port                  = var.bastion_ports[count.index]
  protocol                 = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id        = module.cart.sg_id
}

#cart to allow 8080 from backend alb
resource "aws_security_group_rule" "cart_backend_alb" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = module.backend_alb.sg_id
  security_group_id        = module.cart.sg_id
}


#security group rule for shipping
#shipping to allow 22, 8080 from vpn
resource "aws_security_group_rule" "shipping_vpn" {
  count                    = length(var.vpn_ports)
  type                     = "ingress"
  from_port                = var.vpn_ports[count.index]
  to_port                  = var.vpn_ports[count.index]
  protocol                 = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id        = module.shipping.sg_id
}
#shipping to allow 22,8080 from bastion
resource "aws_security_group_rule" "shipping_bastion" {
  count                    = length(var.bastion_ports)
  type                     = "ingress"
  from_port                = var.bastion_ports[count.index]
  to_port                  = var.bastion_ports[count.index]
  protocol                 = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id        = module.shipping.sg_id
}

#shipping to allow 8080 from backend alb
resource "aws_security_group_rule" "shipping_backend_alb" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = module.backend_alb.sg_id
  security_group_id        = module.shipping.sg_id
}

#security group rule for payment
#payment to allow 22, 8080 form vpn
resource "aws_security_group_rule" "payment_vpn" {
  count                    = length(var.vpn_ports)
  type                     = "ingress"
  from_port                = var.vpn_ports[count.index]
  to_port                  = var.vpn_ports[count.index]
  protocol                 = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id        = module.payment.sg_id
}

#payment to allow 22, 8080 from bastion
resource "aws_security_group_rule" "payment_bastion" {
  count                    = length(var.bastion_ports)
  type                     = "ingress"
  from_port                = var.bastion_ports[count.index]
  to_port                  = var.bastion_ports[count.index]
  protocol                 = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id        = module.payment.sg_id
}

#payment to allow 8080 from backend alb

resource "aws_security_group_rule" "payment_backend_alb" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = module.backend_alb.sg_id
  security_group_id        = module.payment.sg_id
}

#backend alb to allow connections from front end on 80

resource "aws_security_group_rule" "backend_alb_frontend" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = module.frontend.sg_id
  security_group_id        = module.backend_alb.sg_id
}

#backend_alb to allow connections from user on 80
resource "aws_security_group_rule" "backend_alb_user" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = module.user.sg_id
  security_group_id        = module.backend_alb.sg_id
}

#backend_alb to allow connections from cart on 80
resource "aws_security_group_rule" "backend_alb_cart" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = module.cart.sg_id
  security_group_id        = module.backend_alb.sg_id
}

#backend_alb to allow connections from shipping on 80
resource "aws_security_group_rule" "backend_alb_shipping" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = module.shipping.sg_id
  security_group_id        = module.backend_alb.sg_id
}

#backend_alb to allow connections from payment on 80
resource "aws_security_group_rule" "backend_alb_payment" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = module.payment.sg_id
  security_group_id        = module.backend_alb.sg_id
}

#front end to allow 22 from vpn
resource "aws_security_group_rule" "frontend_vpn" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id        = module.frontend.sg_id
}

#frontend to allow 22 from bastion as we moved front end also to private subnet
resource "aws_security_group_rule" "frontend_bastion" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id        = module.frontend.sg_id
}

#frontend to allow http from frontend alb

resource "aws_security_group_rule" "frontend_frontend_alb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = module.frontend_alb.sg_id
  security_group_id        = module.frontend.sg_id
}

#frontend_alb to allow 80 http from internet # we dont need this because we allow 443-https only from internet
resource "aws_security_group_rule" "frontend_alb_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.frontend_alb.sg_id
}

#frontend_alb to allow 443 https from internet

resource "aws_security_group_rule" "frontend_alb_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.frontend_alb.sg_id
}


