#create target group to put catalogue instance
resource "aws_lb_target_group" "catalogue" {
  name                 = "${var.project}-${var.environment}-catalogue"
  deregistration_delay = 120 # time for an instance to terminate, not to terminate suddenly as requests may be queue for the instance.
  port                 = 8080
  protocol             = "HTTP"
  vpc_id               = local.vpc_id
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


#triggers automatically when aws instance created triggers_replace
resource "terraform_data" "catalogue" {
  triggers_replace = [
    aws_instance.catalogue.id
  ]

  provisioner "file" {
    source      = "catalogue.sh"
    destination = "/tmp/catalogue.sh"
  }

  connection {
    type     = "ssh"
    user     = "ec2-user"
    password = "DevOps321"
    host     = aws_instance.catalogue.private_ip
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/catalogue.sh",
      "sudo sh /tmp/catalogue.sh catalogue ${var.environment}"
    ]
  }

}

#Stop the instance
resource "aws_ec2_instance_state" "catalogue" {
  instance_id = aws_instance.catalogue.id
  state       = "stopped"
  depends_on  = [terraform_data.catalogue] # start this block only on catalogue terraform_data block completion, otherwise terraform triggers this block while configuring target group, create instance and perform remot exec, to avoid this we used depends_on

}

#take the AMI after instance is stopped, here AMI will be create in AWS
resource "aws_ami_from_instance" "catalogue" {
  name               = "${var.project}-${var.environment}-catalogue"
  source_instance_id = aws_instance.catalogue.id
  depends_on         = [aws_ec2_instance_state.catalogue] #so, here instance gets stopped after executing aws_ec2_instance_state block, terraform_data but if we run terraform plan/apply, this aws_instance will be startged again as there would be a record in state saing this record was stopped. to prevent this, we need to delete the instance. We did not make any changes to target group, so no changes are applied there.
  tags = merge(local.common_tags,
    {
      Name = "${var.project}-${var.environment}-catalogue" #name given to AMI
  })

}

#make sure you have aws configure in your laptop
resource "terraform_data" "catalogue_delete" {
  triggers_replace = [aws_instance.catalogue.id]

  provisioner "local-exec" {
    command = "aws ec2 terminate-instances --instance-ids ${aws_instance.catalogue.id}" #command to terminate instance

  }
  depends_on = [aws_ami_from_instance.catalogue]
}

#create target group
resource "aws_launch_template" "catalogue" {
  name = "${var.project}-${var.environment}-catalogue"


  image_id = aws_ami_from_instance.catalogue.id #created above

  instance_initiated_shutdown_behavior = "terminate" # terminate if traffic/load decreases like remove instance once traffic/load reduce

  instance_type = "t3.micro"

  vpc_security_group_ids = [local.catalogue_sg_id]

  update_default_version = true # each time when we do terraform apply, new launch template will be created, to avoid this, only to create new version we have this option to make every resource created here to have latest config and to avoid ASG to use old version.

  # launch template will create both instance ebs volume (voulme for instance). So, specify tags for both
  #ec2 tags created by ASG
  tag_specifications {
    resource_type = "instance"

    tags = merge(local.common_tags,
      {
        Name = "${var.project}-${var.environment}-catalogue"
    })
  }
  #volume tags created by ASG
  tag_specifications {
    resource_type = "volume"

    tags = merge(local.common_tags,
      {
        Name = "${var.project}-${var.environment}-catalogue"
    })
  }

  #launch template tags
  tags = merge(local.common_tags,
    {
      Name = "${var.project}-${var.environment}-catalogue"
  })
}


#autoscaling group - refresh all instance once this ASG is updated

resource "aws_autoscaling_group" "catalogue" {
  name             = "${var.project}-${var.environment}-catalogue"
  desired_capacity = 1  #our wish, here I want one instance to be running at a time
  max_size         = 10 #I want to increase no of instances size to 10 if traffic increases
  min_size         = 1  # I want min 1 istance to be running always

  health_check_grace_period = 90    # time to check the health, just do helath check after instance gets created/loaded fully
  health_check_type         = "ELB" #elastic load balancer

  target_group_arns   = [aws_lb_target_group.catalogue.arn] # launch/psh instances into target group from ASG
  vpc_zone_identifier = local.private_subnet_ids            #already we are calling list, so need to mention like []


  launch_template {
    id      = aws_launch_template.catalogue.id
    version = aws_launch_template.catalogue.latest_version
  }

  dynamic "tag" {

    for_each = merge(local.common_tags,
    { Name = "${var.project}-${var.environment}-catalogue" })

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }

  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["launch_template"] #once launch template changes, ASG will retrigger and takes new lauch template, delete old instances and roll out new instances
  }

  timeouts {
    #create = "15m"
    delete = "15m" #delete instances once they finish thier requests
  }
}


#auto scaling group policy # cpu utilization policy

resource "aws_autoscaling_policy" "catalogue" {
  name                   = "${var.project}-${var.environment}-catalogue"
  autoscaling_group_name = aws_autoscaling_group.catalogue.name
  policy_type            = "TargetTrackingScaling" # track the target and scale
  #cooldown               = 120                     #collect cpu metrics after 120 sec │ Error: cooldown is only supported for policy type SimpleScaling
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 70.0
  }
}

#add listener rule to load balancer
#if any url contains *.catalogue.backend-dev.devopspract.site, it will be forwarded to catalogue target group
resource "aws_alb_listener_rule" "catalogue" {
  listener_arn = local.backend_alb_listener_arn
  priority     = 10
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.catalogue.arn
  }
  condition {
    host_header {
      values = ["catalogue.backend-${var.environment}.${var.route53_zone_name}"]
    }
  }
}