# output "az_info" {
# value = module.vpc.av_zone
# }

output "subnet_ids" {
  value = module.vpc.public_subnet_ids
}
