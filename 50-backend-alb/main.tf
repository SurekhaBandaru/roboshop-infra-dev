module "backend_alb" {
  source = "terraform-aws-modules/alb/aws"

  name                  = "${var.project}-${var.environment}-bakend-alb" #roboshop-dev-backend-alb
  vpc_id                = local.vpc_id
  subnets               = local.private_subnet_ids # as we need to created this alb in private subnet
  create_security_group = false                    # as we have created our sg for backend_alb
  security_groups       = [local.backend_alb_sg_id]

  access_logs = {
    bucket = "my-alb-logs"
  }

  listeners = {
    ex-http-https-redirect = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
    ex-https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012"

      forward = {
        target_group_key = "ex-instance"
      }
    }
  }

  target_groups = {
    ex-instance = {
      name_prefix = "h1"
      protocol    = "HTTP"
      port        = 80
      target_type = "instance"
    }
  }

  tags = {
    Environment = "Development"
    Project     = "Example"
  }
}