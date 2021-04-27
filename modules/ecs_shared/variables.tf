// Naming variables
variable "company" {
  type = string
}
variable "region" {
  type = string
}
variable "environment" {
  type = string
}

// Launch configuration variables
variable "image_id" {
  type = string
}
variable "launch_config_security_groups" {
  type = list(string)
}
variable "key_pair" {
  type = string
}

// ASG variables
variable "spot_instance_types" {
  type = list(string)
}
variable "subnet_ids" {
  type = list(string)
}
//variable "desired_capacity" {
//  type = number
//  default = 1
//}
variable "max_size" {
  type = number
  default = 1
}
variable "min_size" {
  type = number
  default = 1
}

variable "internet_gateway" {
  type = string
}
variable "capacity_target_percent" {
  type = number
}