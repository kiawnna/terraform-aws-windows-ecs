// Naming variables
variable "region" {
  type = string
}
variable "environment" {
  type = string
}
variable "company" {
  type = string
}

// ALB variables
variable "security_groups" {
  type = list(string)
}
variable "subnets" {
  type = list(string)
}
variable "cert_arn" {
  type = string
}
