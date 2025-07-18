variable "project" {
  default = "roboshop"
}

variable "environment" {
  default = "dev"
}

variable "frontend_sg_name" {
  default = "frontend"
}

variable "frontend_sg_description" {
  default = "Created sg for frontend instance"
}

variable "bastion_sg_name" {
  default = "bastion"
}

variable "bastion_sg_description" {
  default = "Created sg for bastion instance"
}

variable "backend_alb_sg_name" {
  default = "backend_alb"
}

variable "backend_alb_sg_description" {
  default = "Created sg for backend alb instance"
}

variable "frontend_alb_sg_name" {
  default = "frontend_alb"
}

variable "frontend_alb_sg_description" {
  default = "Created sg for frontend alb instance"
}

variable "vpn_sg_name" {
  default = "vpn"
}

variable "vpn_sg_description" {
  default = "Created sg for vpn instance"
}

variable "mongodb_sg_name" {
  default = "mongodb"
}

variable "mongodb_sg_description" {
  default = "Created sg for mongodb instance"
}

variable "mongodb_ports" {
  default = ["22", "27017"]
}

variable "redis_ports" {
  default = ["22", "6379"]
}

variable "mysql_ports" {
  default = ["22", "3306"]
}


variable "rabbitmq_ports" {
  default = ["22", "5679"]
}


variable "redis_sg_name" {
  default = "redis"
}

variable "redis_sg_description" {
  default = "Created sg for redis instance"
}



variable "mysql_sg_name" {
  default = "mysql"
}

variable "mysql_sg_description" {
  default = "Created sg for mysql instance"
}


variable "rabbitmq_sg_name" {
  default = "rabbitmq"
}

variable "rabbitmq_sg_description" {
  default = "Created sg for rabbitmq instance"
}

variable "catalogue_sg_description" {
  default = "Created sg for catalogue instance"
}

variable "catalogue_sg_name" {
  default = "catalogue"
}

variable "user_sg_name" {
  default = "user"

}

variable "user_sg_description" {
  default = "Created sg for user instance"
}

variable "cart_sg_name" {
  default = "cart"

}

variable "cart_sg_description" {
  default = "Created sg for cart instance"
}

variable "shipping_sg_name" {
  default = "shipping"

}

variable "shipping_sg_description" {
  default = "Created sg for shipping instance"
}

variable "payment_sg_name" {
  default = "payment"

}

variable "payment_sg_description" {
  default = "Created sg for payment instance"
}


variable "vpn_ports" {
  default = ["22", "8080"]
}

variable "bastion_ports" {
  default = ["22", "8080"]
}