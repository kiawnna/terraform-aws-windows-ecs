// ECS resources that need to be deployed per application.
data "aws_caller_identity" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

// ECS Service.
resource "aws_ecs_service" "ecs-service" {
  name            = "${var.company}-${var.app_name}-${var.region}-${var.environment}-ecs-service"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.ecs-task-definition.arn
  desired_count   = var.task_desired_count

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = "${var.company}-${var.app_name}-${var.region}-${var.environment}-container"
    container_port   = var.container_port
  }

  capacity_provider_strategy {
    capacity_provider = var.capacity_provider_name
    weight = 1
  }

  tags = {
    Name = "${var.company}-${var.app_name}-${var.region}-${var.environment}-ecs-service"
    Deployment_Method = "terraform"
  }
}

// Task definition for application.
resource "aws_ecs_task_definition" "ecs-task-definition" {
  family             = "${var.company}-${var.app_name}-${var.region}-${var.environment}-task-definition"
  task_role_arn      = var.task_role_arn

  tags = {
    Name = "${var.company}-${var.app_name}-${var.region}-${var.environment}-task-definition"
    Deployment_Method = "terraform"
  }
  container_definitions = <<-EOF
[
  {
    "name": "${var.company}-${var.app_name}-${var.region}-${var.environment}-container",
    "image": "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com/${aws_ecr_repository.repository.name}:latest",
    "memory": ${var.container_memory},
    "cpu": ${var.container_cpu},
    "essential": true,
    "portMappings": [
      {
        "protocol": "tcp",
        "containerPort": ${var.container_port}
      }
    ]
  }
]
EOF
}

// Listener rule for application.
resource "aws_lb_listener_rule" "app_listener_rule" {
  listener_arn = var.listener_arn
  priority     = random_integer.priority.result

  lifecycle {
    create_before_destroy = true
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }

  condition {
    host_header {
      values = [var.subdomain]
    }
  }
}
resource "random_integer" "priority" {
  min     = 1
  max     = 50000
  keepers = {
    # Generate a new integer each time we switch to a new listener ARN
    listener_arn = var.listener_arn
  }
}

// Target group for application.
resource "aws_lb_target_group" "target_group" {
  name = substr("${var.company}-${var.app_name}-${var.region}-${var.environment}-tg", 0, var.substring_length_tg)
  port = var.container_port
  protocol = var.protocol
  vpc_id = var.vpc_id
  depends_on = [var.load_balancer_arn]

  tags = {
    Name = "${var.company}-${var.app_name}-${var.region}-${var.environment}-tg"
    Deployment_Method = "terraform"
  }

  health_check {
    enabled = true
    matcher = "200-304"
    protocol = "HTTP"
    path = var.health_check_path
    timeout = 60
    interval = 61
    healthy_threshold = 2
  }
}

// Cloudwatch group/alarms for application.
resource "aws_cloudwatch_log_group" "log_group" {
  name             = "${var.company}-${var.app_name}-${var.region}-${var.environment}-log-grp"
  tags = {
    Name = "${var.company}-${var.app_name}-${var.region}-${var.environment}-log-grp"
    Deployment_Method = "terraform"
  }
}

locals {
  target_group_id = aws_lb_target_group.target_group.id
}

resource "aws_cloudwatch_metric_alarm" "httpcode_target_5xx_count" {
  alarm_name          = "${var.prefix}alb-tg-${local.target_group_id}-high5XXCount-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_period
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = var.statistic_period
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "Average API 5XX target group error code count is too high"
  alarm_actions       = var.actions_alarm
  ok_actions          = var.actions_ok

  dimensions = {
    "TargetGroup"  = aws_lb_target_group.target_group.id
    "LoadBalancer" = var.load_balancer_id
  }
}

// Links a certificate to the app
resource "aws_lb_listener_certificate" "app-domain-certificate" {
  listener_arn    = var.listener_arn
  certificate_arn = var.app_certificate_arn
}

// Creates a record for each app.
resource "aws_route53_record" "record" {
  zone_id = var.hosted_zone_id
  name    = var.subdomain
  type    = var.record_type
  alias {
    name                   = var.lb_dns_name
    zone_id                = data.aws_elb_hosted_zone_id.ALB.id
    evaluate_target_health = false
  }
}

data "aws_elb_hosted_zone_id" "ALB" {}

// ECR and policy
resource "aws_ecr_repository" "repository" {
  name = "${var.app_name}-${var.environment}"
}

resource "aws_ecr_repository_policy" "policy" {
  repository = aws_ecr_repository.repository.name

  policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "policy",
            "Effect": "Allow",
            "Principal": {
                "Service": [
                  "codebuild.amazonaws.com",
                  "ecs-tasks.amazonaws.com",
                  "ecs.amazonaws.com",
                  "ec2.amazonaws.com"
                ]
            },
            "Action": [
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability",
                "ecr:PutImage",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload",
                "ecr:DescribeRepositories",
                "ecr:GetRepositoryPolicy",
                "ecr:ListImages",
                "ecr:DeleteRepository",
                "ecr:BatchDeleteImage",
                "ecr:SetRepositoryPolicy",
                "ecr:DeleteRepositoryPolicy"
            ]
        }
    ]
}
EOF
}
## ECS Autoscaling at the task level
#####
# Autoscaling Target
#####
resource "aws_appautoscaling_target" "target" {
  resource_id        = "service/${var.cluster_name}/${aws_ecs_service.ecs-service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = var.min_task_capacity
  max_capacity       = var.max_task_capacity
  service_namespace  = "ecs"
}

#####
# Autoscaling Policies
#####
resource "aws_appautoscaling_policy" "cpu_utilization" {
  name = "${var.company}-${var.app_name}-${var.region}-${var.environment}-ecsScalPolicy"
  policy_type = "TargetTrackingScaling"
  resource_id = "service/${var.cluster_name}/${aws_ecs_service.ecs-service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  target_tracking_scaling_policy_configuration {
    target_value = 75
    scale_in_cooldown = 60
    scale_out_cooldown = 60
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
  depends_on = [aws_appautoscaling_target.target]
}