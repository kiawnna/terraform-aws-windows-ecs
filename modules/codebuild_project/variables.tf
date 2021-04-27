variable "app_name" {
  type = string
}
variable "company_name" {
  type = string
}
variable "environment" {
  type = string
}
variable "project_name" {
  type = string
}
variable "codebuild_role" {
  type = string
}
//variable "github_location" {
//  type = string
//}

variable "artifact_bucket" {
  type = string
}

variable "buildspec" {
  type = string
  default = <<-EOF
version: 0.2

phases:
  install:
    runtime-versions:
      nodejs: 12
  build:
    commands:
      - echo 'Hello, World.'
  EOF
}
variable "image" {
  type    = string
  default = "aws/codebuild/standard:3.0"
}
variable "tags" {
  type = object({
    Environment       = string
    Company           = string
    Deployment_Method = string
    App_Name          = string
  })
}
variable "env_vars" {
  type = list(object({
    name  = string
    value = string
    type = string
  }))
  default = []
}
variable "vpc_config" {
  type = list(object({
    vpc_id             = string
    subnets            = list(string)
    security_group_id = string
  }))
  default = []
}
variable "compute_type" {
  type = string
  default = "BUILD_GENERAL1_SMALL"
}