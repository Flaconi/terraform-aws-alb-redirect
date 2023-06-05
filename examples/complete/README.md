# Example

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_tls"></a> [tls](#provider\_tls) | >= 4 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4 |

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
| <a name="output_redirect_dns_name"></a> [redirect\_dns\_name](#output\_redirect\_dns\_name) | Application Load Balancer fqdn |
| <a name="output_redirect_zone_id"></a> [redirect\_zone\_id](#output\_redirect\_zone\_id) | Application Load Balancer Route53 Zone ID |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
