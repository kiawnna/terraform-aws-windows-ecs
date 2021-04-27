variable "vpc_id" {
  type = string
}
variable "security_group_name" {
  type = string
}

// Ingress and egress rules variables
variable "ingress_rules" {
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_block  = string
  }))

  default = []
}
variable "sg_ingress_rules" {
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    security_groups  = list(string)
  }))

  default = []
}
variable "egress_rules" {
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_block  = string
  }))
}