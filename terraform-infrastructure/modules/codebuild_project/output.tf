output "project_name" {
  value = aws_codebuild_project.project.name
}
output "project_short_name" {
  value = var.project_name
}
output "project_arn" {
  value = aws_codebuild_project.project.arn
}
