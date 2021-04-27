variable "app_name" {
  type = string
}
variable "company_name" {
  type = string
}
variable "environment" {
  type = string
}
variable "pipeline_name" {
  type = string
}
variable "bucket" {
  type = string
}
variable "role_arn" {
  type = string
}
variable "github_token" {
  type = string
  default = ""
}
variable "sns_topic_arn" {
  type = string
  default = ""
}
variable "tags" {
  type = object({
    Environment       = string
    Company           = string
    Deployment_Method = string
    App_Name          = string
  })
}
variable "source_actions" {
  type = list(object({
    output_artifact = string
    name = string
    repo = string
    branch = string
    owner = string
    poll = string
  }))
  default = []
}
variable "s3_source_actions" {
  type = list(object({
    output_artifact = string
    name = string
    bucket = string
    key = string
  }))
  default = []
}
variable "test_projects" {
  type = list(object({
    name = string
    short_name = string
    run_order = number
    input_artifact = string
  }))
  default = []
}
variable "migrate_projects" {
  type = list(object({
    name = string
    short_name = string
    run_order = number
    input_artifact = string
  }))
  default = []
}
variable "build_projects" {
  type = list(object({
    name = string
    short_name = string
    run_order = number
    input_artifact = string
  }))
  default = []
}
variable "post_build_projects" {
  type = list(object({
    name = string
    short_name = string
    run_order = number
    input_artifact = string
  }))
  default = []
}
variable "approve_actions" {
  type = list(object({
    name = string
    short_name = string
    sns_topic_arn = string
  }))
  default = []
}
variable "poll_for_source_changes" {
  type = string
  default = "true"
}
