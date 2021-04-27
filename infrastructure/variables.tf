// Generic variables
variable "region" {
  type = string
  default = "us-west-2"
}
variable "company" {
  type = string
}

// Environment Specific
variable "environment" {
  type = string
}
variable "branch" {
  type = string
}
variable "task_desired_count" {
  type = number
}
variable "container_cpu" {
  type = number
}
variable "container_memory" {
  type = number
}
variable "max_size_ecs_hosts" {
  type = number
}
variable "key_pair" {
  type = string
}
variable "ami_id" {
  type = string
}
variable "load_balancer_cert_arn" {
  type = string
}
variable "github_token" {
  type = string
}
variable "github_owner" {
  type = string
}
variable "max_task_capacity" {
  type = string
}
variable "bastion_ami_id" {
  type = string
}

// Application: EXAMPLE
variable "example_subdomain" {
  type = string
}
variable "example_app_name" {
  type = string
}
variable "example_app_certificate_arn" {
  type = string
}
variable "example_hosted_zone_id" {
  type = string
}
variable "example_repo" {
  type = string
}
variable "example_port" {
  type = string
}

// S3 Website: s3example
variable "s3example_website_domain_name" {
  type = string
}
variable "s3example_acm_cert_arn" {
  type = string
}
variable "s3example_hosted_zone_id" {
  type = string
}
variable "s3example_app_name" {
  type = string
}
variable "s3example_repo" {
  type = string
}
variable "s3example_website_redirect_domain" {
  type = string
}
variable "s3example_redirect_hosted_zone_id" {
  type = string
}
variable "capacity_target_percent" {
  type = number
}