locals {
  vpc_id = data.aws_ssm_parameter.vpc_id.value #get from data source, from 00-vpc, it got stored into ssm param, so we used data source to bring till here
}