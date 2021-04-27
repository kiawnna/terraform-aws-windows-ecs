output "target_group_arn" {
  value = aws_lb_target_group.target_group.arn
}

output "ecr_url" {
  value = aws_ecr_repository.repository.repository_url
}

output "ecs_service_name" {
  value = aws_ecs_service.ecs-service.name
}