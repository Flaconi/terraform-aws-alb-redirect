# Terraform AWS ALB Redirect

[![Build Status](https://travis-ci.com/Flaconi/terraform-aws-alb-redirect.svg?branch=master)](https://travis-ci.com/Flaconi/erraform-aws-alb-redirect)
[![Tag](https://img.shields.io/github/tag/Flaconi/terraform-aws-alb-redirect.svg)](https://github.com/Flaconi/terraform-aws-alb-redirect/releases)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

This Terraform module can create HTTP 301 and 302 redirects using the AWS Application Load Balancer

## Usage

### alb_redirect module

```hcl
module "alb_redirect" {
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

  # certificate_arn sets the certificate arn for the https listener, not mandatory
  certificate_arn = aws_acm_certificate.acme[0].arn

  # extra_ssl_certs sets the extra ssl certificate arns applied to the SSL Listener, not mandagtory
  extra_ssl_certs = [aws_acm_certificate.acme[1].arn, aws_acm_certificate.acme[2].arn]

  # extra_ssl_certs_count, the count of the extra_ssl_certs
  extra_ssl_certs_count = 2

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
      # redirect_status_code     = "HTTP_302"
      # redirect_query     = "#{query}"
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
```

## Resources

The following resources _CAN_ be created:

- 1 VPC
- 1 IGW
- 2 Subnets
- 1 Routing Table
- 1 Security Group
- 1 LB
- 2 HTTP Listeners ( HTTP / HTTPS)
- 2 HTTP Listener Rules

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| name | The name used to interpolate into the resources created | string | n/a | yes |
| certificate\_arn | The arn of the certificate | string | `""` | no |
| cidr | The cidr used for the network | string | `"172.30.0.0/16"` | no |
| extra\_ssl\_certs | The extra ssl certifice arns applied to the SSL Listener | list | `[]` | no |
| extra\_ssl\_certs\_count | The count of the extra_ssl_certs | string | `"0"` | no |
| https\_enabled | Do we enable https | string | `"false"` | no |
| lb\_ip\_address\_type | The `ip_address_type` of the LB, either 'ipv4' or 'dualstack' in case ipv6 needs to be supported as well | string | `"ipv4"` | no |
| redirect\_rules | A list with maps populated with redirect rules | list | `[]` | no |
| response\_code | The default status code to return when no rules have been met | string | `"500"` | no |
| response\_message\_body | The default response message body in case no rules have been met | string | `"No match"` | no |
| tags | Extra tags to be applied to the resources | map | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| this\_lb\_dns\_name | Application Load Balancer fqdn |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## License

[MIT](LICENSE)

Copyright (c) 2019 [Flaconi GmbH](https://github.com/Flaconi)
