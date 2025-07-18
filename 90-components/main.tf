module "component" {
  for_each      = var.components
  source        = "git::https://github.com/SurekhaBandaru/terraform-aws-roboshop.git?ref=main"
  component     = each.key #cart, shipping, payment
  rule_priority = each.value.rule_priority

}