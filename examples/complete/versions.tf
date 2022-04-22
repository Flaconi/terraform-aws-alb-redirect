terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 3.3"
    }
  }
  required_version = ">= 0.14"
}
