// Naming variables
variable "app_name" {
  type = string
}
variable "company" {
  type = string
}
variable "region" {
  type = string
}
variable "environment" {
  type = string
}

// Container variables
variable "container_port" {
  type = string
}
//variable "container_image" {
//  type = string
//}
variable "container_cpu" {
  type = string
}
variable "container_memory" {
  type = string
}

// IAM variables
variable "task_role_arn" {
  type = string
}
variable "task_execution_role_arn" {
  type = string
}

// ECS service variables
variable "subnets" {
  type = list(string)
}
variable "security_groups" {
  type = list(string)
}
variable "capacity_provider_name" {
  type = string
}
variable "ecs_cluster_id" {
  type = string
}

// Target group variables
variable "protocol" {
  type = string
  default = "HTTP"
}
variable "vpc_id" {
  type = string
}
variable "health_check_path" {
  type = string
  default = "/"
}
variable "load_balancer_arn" {
  type = string
}

// Listener Rule variables
variable "listener_arn" {
  type = string
}
variable "subdomain" {
  type = string
}

// Cloudwatch alarm variables
variable "load_balancer_id" {
  type = string
}
variable "prefix" {
  type        = string
  default     = ""
  description = "Alarm Name Prefix"
}
variable "response_time_threshold" {
  type        = string
  default     = "50"
  description = "The average number of milliseconds that requests should complete within."
}
variable "evaluation_period" {
  type        = string
  default     = "5"
  description = "The evaluation period over which to use when triggering alarms."
}
variable "statistic_period" {
  type        = string
  default     = "60"
  description = "The number of seconds that make each statistic period."
}
variable "actions_alarm" {
  type        = list(string)
  default     = []
  description = "A list of actions to take when alarms are triggered. Will likely be an SNS topic for event distribution."
}
variable "actions_ok" {
  type        = list(string)
  default     = []
  description = "A list of actions to take when alarms are cleared. Will likely be an SNS topic for event distribution."
}

// Route 53 variables
variable "hosted_zone_id" {
  type = string
}
variable "record_type" {
  type = string
  default = "A"
}
variable "lb_dns_name" {
  type = string
}

// Certificate variables
variable "app_certificate_arn" {
  type = string
}

variable "substring_length_tg" {
  type = number
}
variable "task_desired_count" {
  type = number
  default = 1
}

# ECS AUTOSCALING VARIABLES
variable "cluster_name" {
  type = string
}
variable "min_task_capacity" {
  type = number
}
variable "max_task_capacity" {
  type = number
}