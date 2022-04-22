provider "aws" {
  region = "us-east-1"
}

locals {
  ssl_domains = ["somehost.tld", "somehost2.tld", "somehost3.tld"]
}

resource "tls_private_key" "this" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "acme" {
  count           = 3
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.this.private_key_pem

  subject {
    common_name  = local.ssl_domains[count.index]
    organization = "ACME Examples, Inc"
  }

  validity_period_hours = 12

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "aws_acm_certificate" "acme" {
  count            = 3
  private_key      = tls_private_key.this.private_key_pem
  certificate_body = tls_self_signed_cert.acme[count.index].cert_pem
}

module "redirect" {
  source = "../../"

  name = "redirect-service"

  # This can be left to its default
  # cidr = "172.30.0.0/16"

  # extra tags to be applied to the resources
  tags = {
    Terraform = "generated"
  }

  # do we enable the https listener
  https_enabled = true

  # certificate_arn sets the certificate arn for the httpx listener
  certificate_arn = aws_acm_certificate.acme[0].arn

  # extra_ssl_certs sets the extra ssl certificate arns applied to the SSL Listener
  extra_ssl_certs = {
    cert1 = aws_acm_certificate.acme[1].arn
    cert2 = aws_acm_certificate.acme[2].arn
  }

  # lb_ip_address_type sets the `ip_address_type` of the LB, either 'ipv4' or 'dualstack' in case ipv6 needs to be supported as well
  # lb_ip_address_type = "ipv4"

  # response_message_body sets the default response message body in case no rules have been met"
  # response_message_body = "No Match"

  # response_code sets the status code to return when no rules have been met"
  # response_code = 500

  redirect_rules = [
    {
      # Match host `somehost.tld`, match path `/wikipedia` 302 forward to https://www.wikipedia.org/
      # unless redirect_query is set to "" the query params will be kept by default
      # path will be preserved
      # status code will be 302 by default
      host_match        = "somehost.tld"
      path_match        = "/wikipedia"
      redirect_host     = "www.wikipedia.org"
      redirect_protocol = "HTTPS"
      redirect_path     = "/"
      redirect_port     = "443"
      # redirect_status_code = "HTTP_302"
      # redirect_query       = ""
    },
    {
      # Match host `somehost2.tld`, match all paths, permanent forward to https://example.com
      # path will be preserved
      # query params will be preserved
      path_match           = "*"
      host_match           = "somehost2.tld"
      redirect_host        = "example.com"
      redirect_protocol    = "HTTPS"
      redirect_path        = "/#{path}"
      redirect_status_code = "HTTP_301"
      redirect_port        = "443"
      redirect_query       = ""
    },
    {
      # Match host `somehost3.tld`, match all paths, forward to http://http-redir-cannot-be-created-on-https-listener.example.com
      # path will be preserved
      # query params will be preserved
      # this will only work on http listener as redirects from HTTPS to HTTP are not supported, hence we disable it for HTTPS
      path_match        = "*"
      host_match        = "somehost3.tld"
      redirect_host     = "http-redir-cannot-be-created-on-https-listener.example.com"
      redirect_protocol = "HTTP"
      redirect_path     = "/"
      redirect_port     = "80"
      disabled_for      = "HTTPS"
    },
    {
      path_match        = "/danger-forward-all-uris-of-all-hosts'"
      host_match        = "*"
      redirect_host     = "to-this-subdomain-of.example.com"
      redirect_protocol = "HTTPS"
      redirect_path     = "/"
      redirect_port     = "80"
    }
  ]
}
