output "bucket_name" {
  value = aws_s3_bucket.website_root.bucket
}
output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.website_cdn_root.id
}