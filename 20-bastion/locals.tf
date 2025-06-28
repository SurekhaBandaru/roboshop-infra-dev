locals {
  ami_id           = data.aws_ami.joindevops84s.id # from data source
  bastion_sg_id    = data.aws_ssm_parameter.bastion_sg_id.value
  public_subnet_id = split(",", data.aws_ssm_parameter.public_subnet_ids.value)[0] # as we are getting two subnets here, taking the first subnet
  common_tags = {
    Project     = var.project
    Environment = var.environment
    Terraform   = true
  }
}