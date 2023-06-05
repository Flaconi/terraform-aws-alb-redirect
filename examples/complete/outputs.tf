output "redirect_dns_name" {
  value       = module.redirect.dns_name
  description = "Application Load Balancer fqdn"
}

output "redirect_zone_id" {
  value       = module.redirect.zone_id
  description = "Application Load Balancer Route53 Zone ID"
}
