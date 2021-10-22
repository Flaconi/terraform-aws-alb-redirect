# Example

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_tls"></a> [tls](#provider\_tls) | n/a |
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_redirect"></a> [redirect](#module\_redirect) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.acme](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [tls_private_key.this](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_self_signed_cert.acme](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert) | resource |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_redirect_this_lb_dns_name"></a> [redirect\_this\_lb\_dns\_name](#output\_redirect\_this\_lb\_dns\_name) | Application Load Balancer fqdn |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
