output "launch_template_id" {
  value = aws_launch_template.launch-template.id
}
output "ecs_cluster_id" {
  value = aws_ecs_cluster.ecs-cluster.id
}
output "ecs_cluster_name" {
  value = aws_ecs_cluster.ecs-cluster.name
}
output "capacity_provider_name" {
  value = aws_ecs_capacity_provider.capacity-provider.name
}
output "iam_instance_profile_arn" {
  value = aws_iam_instance_profile.ecs_host_instance_profile.arn
}
output "task_role_arn" {
  value = aws_iam_role.task_role.arn
}
output "task_execution_role_arn" {
  value = aws_iam_role.task_execution_role.arn
}