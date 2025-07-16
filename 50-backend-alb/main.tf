module "backend_alb" {
  source                     = "terraform-aws-modules/alb/aws"
  version                    = "9.16.0"                                        # as we used open source, they are using this version lastest
  internal                   = true                                            # false if load balancer is public/internal
  name                       = "${var.project}-${var.environment}-backend-alb" #roboshop-dev-backend-alb
  vpc_id                     = local.vpc_id
  subnets                    = local.private_subnet_ids # as we need to created this alb in private subnet
  create_security_group      = false                    # as we have created our sg for backend_alb
  security_groups            = [local.backend_alb_sg_id]
  enable_deletion_protection = false # to avoid  cannot be deleted because deletion protection is enabled


  tags = merge(local.common_tags,
    {
      Name = "${var.project}-${var.environment}-backend-alb"
    }
  )
}

#gives fixed output without target group
resource "aws_alb_listener" "backend_alb" {
  load_balancer_arn = module.backend_alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<h1> Hello, I am Fixed Response Content from listener (backend ALB) </h1>"
      status_code  = "200"
    }
  }
}

#here it is difficult to remember dns created in alb, we can create it route 53 record as shown

resource "aws_route53_record" "backend_alb" {

  zone_id = var.route53_zone_id
  name    = "*.backend-dev.${var.route53_zone_name}"
  type    = "A"
  alias {
    name                   = module.backend_alb.dns_name
    zone_id                = module.backend_alb.zone_id # zone id of alb
    evaluate_target_health = true
  }
  allow_overwrite = true

}




