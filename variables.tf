variable "name" {
  type        = string
  description = "The name used to interpolate into the resources created"
}
variable "cidr" {
  type        = string
  default     = "172.30.0.0/16"
  description = "The cidr used for the network"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Extra tags to be applied to the resources"
}

variable "https_enabled" {
  type        = bool
  default     = false
  description = "Do we enable https"
}

variable "certificate_arn" {
  type        = string
  default     = ""
  description = "The arn of the certificate"
}

variable "extra_ssl_certs" {
  type        = set(string)
  default     = []
  description = "The extra ssl certifice arns applied to the SSL Listener"
}

variable "redirect_rules" {
  type        = list(map(string))
  default     = []
  description = "A list with maps populated with redirect rules"
}

variable "lb_ip_address_type" {
  type        = string
  default     = "ipv4"
  description = "The `ip_address_type` of the LB, either 'ipv4' or 'dualstack' in case ipv6 needs to be supported as well"
}

variable "ipv6_networking_enabled" {
  type        = bool
  default     = false
  description = "Do we configure IPv6 routing and ingress in the VPC"
}

variable "response_message_body" {
  type        = string
  default     = "No match"
  description = "The default response message body in case no rules have been met"
}

variable "response_code" {
  type        = string
  default     = "500"
  description = "The default status code to return when no rules have been met"
}

variable "ssl_policy" {
  description = "Security policy used for front-end connections."
  type        = string
  default     = "ELBSecurityPolicy-FS-1-2-Res-2020-10"
}
