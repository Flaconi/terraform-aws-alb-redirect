output "dns_name" {
  description = "Application Load Balancer fqdn"
  value       = aws_lb.this.dns_name
}

output "zone_id" {
  description = "Application Load Balancer Route53 Zone ID"
  value       = aws_lb.this.zone_id
}
