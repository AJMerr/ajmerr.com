output "s3_bucket_name" {
  value = aws_s3_bucket.ajmerr_host.bucket
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.ajmerr_distribution.domain_name
}

output "website_url" {
  value = "https://${aws_cloudfront_distribution.ajmerr_distribution.domain_name}"
}
