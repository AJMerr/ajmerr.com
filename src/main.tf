terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# AWS Provider 
provider "aws" {
  region = var.aws_region
}

# AWS S3 Bucket 
resource "aws_s3_bucket" "ajmerr_host" {
  bucket        = var.s3_bucket_name
  force_destroy = true
}

# AWS S3 Bucket Website Configuration
resource "aws_s3_bucket_website_configuration" "ajmerr_host_website" {
  bucket = aws_s3_bucket.ajmerr_host.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "404.html"
  }
}

# AWS S3 Bucket Policy for public-read
resource "aws_s3_bucket_policy" "ajmerr_host_policy" {
  bucket = aws_s3_bucket.ajmerr_host.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "s3:GetObject",
        Effect    = "Allow",
        Resource  = "${aws_s3_bucket.ajmerr_host.arn}/*",
        Principal = "*"
      }
    ]
  })
}

# Public Access Block for the S3 Bucket
resource "aws_s3_bucket_public_access_block" "ajmerr_host_block" {
  bucket = aws_s3_bucket.ajmerr_host.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Ensure Object Ownership is enforced (disabling ACLs)
resource "aws_s3_bucket_ownership_controls" "ajmerr_host_ownership" {
  bucket = aws_s3_bucket.ajmerr_host.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# AWS CloudFront 
resource "aws_cloudfront_distribution" "ajmerr_distribution" {
  origin {
    domain_name = "${aws_s3_bucket.ajmerr_host.bucket}.s3-website-${var.aws_region}.amazonaws.com"
    origin_id   = "S3-${aws_s3_bucket.ajmerr_host.id}"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  # Creates aliases for my domain
  aliases = ["ajmerr.com", "www.ajmerr.com"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.ajmerr_host.id}"

    viewer_protocol_policy = "redirect-to-https"
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}

# AWS Route53 setup 
resource "aws_route53_record" "ajmerr_dns" {
  zone_id = var.route_53_zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.ajmerr_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.ajmerr_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

