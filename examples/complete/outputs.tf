output "redirect_this_lb_dns_name" {
  value       = module.redirect.this_lb_dns_name
  description = "Application Load Balancer fqdn"
}
