output "cloudfront_domain_name" {
  value       = aws_cloudfront_distribution.s3_distribution.domain_name
  description = "The raw CloudFront distribution URL endpoint."
}

output "application_url" {
  value       = "https://${local.domain_name}"
  description = "The main target application URL."
}
