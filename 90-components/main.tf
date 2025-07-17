module "component" {
  for_each      = var.components
  source        = "../../terraform-aws-roboshop"
  component     = each.key #cart, shipping, payment
  rule_priority = each.value.rule_priority

}