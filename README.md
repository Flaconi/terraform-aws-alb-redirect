# Terraform AWS ALB Redirect

[![Build Status](https://travis-ci.com/Flaconi/terraform-aws-alb-redirect.svg?branch=master)](https://travis-ci.com/Flaconi/erraform-aws-alb-redirect)
[![Tag](https://img.shields.io/github/tag/Flaconi/terraform-aws-alb-redirect.svg)](https://github.com/Flaconi/terraform-aws-alb-redirect/releases)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

This Terraform module can create HTTP 301 and 302 redirects using the AWS Application Load Balancer

<!-- TFDOCS_HEADER_START -->


<!-- TFDOCS_HEADER_END -->

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

<!-- TFDOCS_PROVIDER_START -->
## Providers

| Name | Version |
|------|---------|
| aws | n/a |

<!-- TFDOCS_PROVIDER_END -->

<!-- TFDOCS_REQUIREMENTS_START -->
## Requirements

No requirements.

<!-- TFDOCS_REQUIREMENTS_END -->'

<!-- TFDOCS_INPUTS_START -->
## Required Inputs

The following input variables are required:

### name

Description: The name used to interpolate into the resources created

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### cidr

Description: The cidr used for the network

Type: `string`

Default: `"172.30.0.0/16"`

### tags

Description: Extra tags to be applied to the resources

Type: `map(string)`

Default: `{}`

### https\_enabled

Description: Do we enable https

Type: `bool`

Default: `false`

### certificate\_arn

Description: The arn of the certificate

Type: `string`

Default: `""`

### extra\_ssl\_certs

Description: The extra ssl certifice arns applied to the SSL Listener

Type: `list(string)`

Default: `[]`

### extra\_ssl\_certs\_count

Description: The count of the extra\_ssl\_certs

Type: `number`

Default: `0`

### redirect\_rules

Description: A list with maps populated with redirect rules

Type: `list(map(string))`

Default: `[]`

### lb\_ip\_address\_type

Description: The `ip_address_type` of the LB, either 'ipv4' or 'dualstack' in case ipv6 needs to be supported as well

Type: `string`

Default: `"ipv4"`

### response\_message\_body

Description: The default response message body in case no rules have been met

Type: `string`

Default: `"No match"`

### response\_code

Description: The default status code to return when no rules have been met

Type: `string`

Default: `"500"`

### ssl\_policy

Description: Security policy used for front-end connections.

Type: `string`

Default: `"ELBSecurityPolicy-FS-1-2-Res-2020-10"`

<!-- TFDOCS_INPUTS_END -->

<!-- TFDOCS_OUTPUTS_START -->
## Outputs

| Name | Description |
|------|-------------|
| this\_lb\_dns\_name | Application Load Balancer fqdn |

<!-- TFDOCS_OUTPUTS_END -->


## License

[MIT](LICENSE)

Copyright (c) 2019 [Flaconi GmbH](https://github.com/Flaconi)
