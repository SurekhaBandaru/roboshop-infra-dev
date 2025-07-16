module "fronend_alb" {
  source                     = "terraform-aws-modules/alb/aws"
  version                    = "9.16.0"                                         # as we used open source, they are using this version lastest
  internal                   = false                                            # false if load balancer is public
  name                       = "${var.project}-${var.environment}-frontend-alb" #roboshop-dev-backend-alb
  vpc_id                     = local.vpc_id
  subnets                    = local.public_subnet_ids # as we need to created this alb in public subnets
  create_security_group      = false                   # as we have created our sg for backend_alb
  security_groups            = [local.frontend_alb_sg_id]
  enable_deletion_protection = false # to avoid  cannot be deleted because deletion protection is enabled


  tags = merge(local.common_tags,
    {
      Name = "${var.project}-${var.environment}-frontend-alb"
    }
  )
}

#gives fixed output without target group
resource "aws_alb_listener" "frontend_alb" {
  load_balancer_arn = module.frontend_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08" # It is old policy, we will face issues with CDN
  certificate_arn   = local.acm_certificate_arn
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<h1> Hello, I am Fixed Response Content from listener (frontend ALB HTTPS) </h1>"
      status_code  = "200"
    }
  }
}

#here it is difficult to remember dns created in alb, we can create it route 53 record as shown

resource "aws_route53_record" "backend_alb" {

  zone_id = var.route53_zone_id
  name    = "*.${var.route53_zone_name}" #*.devopspract.site
  type    = "A"
  alias {
    name                   = module.backend_alb.dns_name
    zone_id                = module.backend_alb.zone_id # zone id of alb
    evaluate_target_health = true
  }
  allow_overwrite = true

}




