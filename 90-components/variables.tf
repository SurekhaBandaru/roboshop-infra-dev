variable "components" {
  default = {
    catalogue = {
      rule_priority = 10 # rule_priority should not be same in single load balancer
    }
    user = {
      rule_priority = 20
    }
    cart = {
      rule_priority = 30
    }
    shipping = {
      rule_priority = 40
    }
    payment = {
      rule_priority = 50
    }
    frontend = {
      rule_priority = 10 # here front is having separate load balancer
    }

  }
}