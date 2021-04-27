variable "website-domain-main" {
  description = "Main website domain, e.g. cloudmaniac.net"
  type        = string
}
variable "website-domain-redirect" {
  description = "Secondary FQDN that will redirect to the main URL, e.g. www.cloudmaniac.net"
  default     = null
  type        = string
}
variable "hosted_zone_id" {
  type = string
}
variable "record_type" {
  type = string
  default = "A"
}
variable "acm_certificate_arn" {
  type = string
}
variable "redirect_hosted_zone_id" {
  type = string
}