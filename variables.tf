variable "name" {
  description = "The name used to interpolate into the resources created"
}
variable "cidr" {
  default     = "172.30.0.0/16"
  description = "The cidr used for the network"
}

variable "tags" {
  default     = {}
  description = "Extra tags to be applied to the resources"
}

variable "https_enabled" {
  default     = false
  description = "Do we enable https"
}

variable "certificate_arn" {
  default     = ""
  description = "The arn of the certificate"
}

variable "extra_ssl_certs" {
  default     = []
  description = "The extra ssl certifice arns applied to the SSL Listener"
}

variable "extra_ssl_certs_count" {
  default     = 0
  description = "The count of the extra_ssl_certs"
}

variable "redirect_rules" {
  default     = []
  description = "A list with maps populated with redirect rules"
}

variable "lb_ip_address_type" {
  default     = "ipv4"
  description = "The `ip_address_type` of the LB, either 'ipv4' or 'dualstack' in case ipv6 needs to be supported as well"
}

variable "response_message_body" {
  default     = "No match"
  description = "The default response message body in case no rules have been met"
}

variable "response_code" {
  default     = "500"
  description = "The default status code to return when no rules have been met"
}
