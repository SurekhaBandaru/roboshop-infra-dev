#create target group to put catalogue instance
resource "aws_lb_target_group" "catalogue" {
  name     = "${var.project}-${var.environment}-catalouge"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = local.vpc_id
  health_check {
    healthy_threshold = 2
    interval          = 5 #sec
    matcher           = "200-299"
    path              = "/health" # every back end has /health end point :8080/health as we usually have in controllers java 
    port              = 8080
    #protocol = "HTTP" default, so no need to specify
    timeout             = 2
    unhealthy_threshold = 3 # if we get unhealthy 3 times, it is not working

  }
}

#Catalogue EC2 instance
resource "aws_instance" "catalogue" {
  ami                    = local.ami_id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [local.catalogue_sg_id]
  subnet_id              = local.private_subnet_id
  tags = merge(local.common_tags,
    {
      Name = "${var.project}-${var.environment}-catalogue"
    }
  )
}