output "vpc_self_link" {
  description = "The self-link of the created VPC network"
  value       = module.vpc-hub.self_link
}

output "subnet_self_links" {
  description = "The self-links of the subnets within the VPC network"
  value       = module.vpc-hub.subnet_self_links
}
