output "codebuild_role_arn" {
  value = aws_iam_role.codebuild_role.arn
}

output "artifact_bucket" {
  value = aws_s3_bucket.artifact_bucket.bucket
}

output "artifact_bucket_name" {
  value = aws_s3_bucket.artifact_bucket.id
}
output "pipeline_role_arn" {
  value = aws_iam_role.pipeline_role.arn
}
output "instance_profile_arn" {
  value = aws_iam_instance_profile.ssm_ec2_instance_profile.arn
}