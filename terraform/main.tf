
# locals {
#   domain_name = "cliff.com" 
# }


# ==========================================
#  ROUTE 53 (Domain & Hosted Zone)
# ==========================================
# resource "aws_route53domains_domain" "demo_domain" {
#   domain_name = local.domain_name
#   auto_renew  = false

#   admin_contact {
#     address_line_1    = "101 Main Street"
#     city              = "San Francisco"
#     contact_type      = "COMPANY"
#     country_code      = "US"
#     email             = "terraform-acctest@example.com"
#     fax               = "+1.4155551234"
#     first_name        = "Terraform"
#     last_name         = "Team"
#     organization_name = "HashiCorp"
#     phone_number      = "+1.4155551234"
#     state             = "CA"
#     zip_code          = "94105"
#   }

#   registrant_contact {
#     address_line_1    = "101 Main Street"
#     city              = "kampala"
#     contact_type      = "COMPANY"
#     country_code      = "UG"
#     email             = "gitacliff48@gmail.com"
#     fax               = "+1.4155551234"
#     first_name        = "Gita"
#     last_name         = "cliff"
#     organization_name = "HashiCorp"
#     phone_number      = "+256704567830"
#     state             = "CA"
#     zip_code          = "94105"
#   }

#   tech_contact {
#     address_line_1    = "101 Main Street"
#     city              = "San Francisco"
#     contact_type      = "COMPANY"
#     country_code      = "US"
#     email             = "terraform-acctest@example.com"
#     fax               = "+1.4155551234"
#     first_name        = "Terraform"
#     last_name         = "Team"
#     organization_name = "HashiCorp"
#     phone_number      = "+1.4155551234"
#     state             = "CA"
#     zip_code          = "94105"
#   }

#   tags = {
#     Environment = "dev"
#   }
# }

# resource "aws_route53_zone" "primary_zone" {
#   name = aws_route53domains_domain.demo_domain.domain_name
#   comment = "Managed by cliff"
# }


# # S3 bucket for static website hosting
# resource "aws_s3_bucket" "first_bucket" {
#   bucket = var.bucket_name
#    tags = {
#     Name = var.bucket_tag
#   }
# }

# # Make S3 bucket private
# resource "aws_s3_bucket_public_access_block" "block" {
#   bucket = aws_s3_bucket.first_bucket.id

#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }

# # Origin Access Control for CloudFront (Recommended over OAI)
# resource "aws_cloudfront_origin_access_control" "oac" {
#   name                              = var.oac_name
#   description                       = var.oac_description
#   origin_access_control_origin_type = "s3"
#   signing_behavior                  = "always"
#   signing_protocol                  = "sigv4"
# }


# resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
#   bucket = aws_s3_bucket.first_bucket.id
#   depends_on = [aws_s3_bucket_public_access_block.block]

#   policy = data.aws_iam_policy_document.origin_bucket_policy.json

# }
# data "aws_iam_policy_document" "origin_bucket_policy" {
#   statement {
#     sid    = "AllowCloudFrontServicePrincipalReadWrite"
#     effect = "Allow"

#     principals {
#       type        = "Service"
#       identifiers = ["cloudfront.amazonaws.com"]
#     }

#     actions = [
#       "s3:GetObject"
#     ]

#     resources = [
#       "${aws_s3_bucket.first_bucket.arn}/*",
#     ]

#     condition {
#       test     = "StringEquals"
#       variable = "AWS:SourceArn"
#       values   = [aws_cloudfront_distribution.s3_distribution.arn]
#     }
#   }
# }

# # Upload website files to S3
# resource "aws_s3_object" "website_files" {
#   for_each = fileset("${path.module}/www", "**/*")

#   bucket = aws_s3_bucket.first_bucket.id
#   key    = each.value
#   source = "${path.module}/www/${each.value}"
#   etag   = filemd5("${path.module}/www/${each.value}")
#   content_type = lookup({
#     "html" = "text/html",
#     "css"  = "text/css",
#     "js"   = "application/javascript",
#     "json" = "application/json",
#     "png"  = "image/png",
#     "jpg"  = "image/jpeg",
#     "jpeg" = "image/jpeg",
#     "gif"  = "image/gif",
#     "svg"  = "image/svg+xml",
#     "ico"  = "image/x-icon",
#     "txt"  = "text/plain"
#   }, split(".", each.value)[length(split(".", each.value)) - 1], "application/octet-stream")
# }


# # ==========================================
# # ACM SSL/TLS CERTIFICATE
# # ==========================================

# resource "aws_acm_certificate" "website_cert" {
#   domain_name       = local.domain_name
#   validation_method = "DNS"

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_route53_record" "cert_validation" {
#   for_each = {
#     for dvo in aws_acm_certificate.website_cert.domain_validation_options : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       record = dvo.resource_record_value
#       type   = dvo.resource_record_type
#     }
#   }

#   zone_id = aws_route53_zone.primary_zone.zone_id

#   name            = each.value.name
#   type            = each.value.type
#   records         = [each.value.record]
#   ttl             = 60
#   allow_overwrite = true
# }

# resource "aws_acm_certificate_validation" "website_cert" {
#   certificate_arn = aws_acm_certificate.website_cert.arn

#   validation_record_fqdns = [
#     for record in aws_route53_record.cert_validation :
#     record.fqdn
#   ]
# }

# # Create Route53 records for the CloudFront distribution aliases
# resource "aws_route53_record" "cloudfront" {
#   for_each = aws_cloudfront_distribution.s3_distribution.aliases
#   zone_id  = aws_route53_zone.primary_zone.zone_id
#   name     = each.value
#   type     = "A"

#   alias {
#     name                   = aws_cloudfront_distribution.s3_distribution.domain_name
#     zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
#     evaluate_target_health = false
#   }
# }

# resource "aws_cloudfront_distribution" "s3_distribution" {

#   enabled             = true
#   is_ipv6_enabled     = true
#   default_root_object = "index.html"

#   # Custom domain
#   aliases = [local.domain_name]

#   origin {
#     domain_name              = aws_s3_bucket.first_bucket.bucket_regional_domain_name
#     origin_id                = "S3-${aws_s3_bucket.first_bucket.id}"
#     origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
#   }

#   default_cache_behavior {
#     allowed_methods  = ["GET", "HEAD"]
#     cached_methods   = ["GET", "HEAD"]
#     target_origin_id = "S3-${aws_s3_bucket.first_bucket.id}"

#     forwarded_values {
#       query_string = false

#       cookies {
#         forward = "none"
#       }
#     }

#     # Force HTTP → HTTPS
#     viewer_protocol_policy = "redirect-to-https"

#     min_ttl     = 0
#     default_ttl = 3600
#     max_ttl     = 86400
#   }

#   price_class = "PriceClass_100"

#   restrictions {
#     geo_restriction {
#       restriction_type = "none"
#     }
#   }

#   # HTTPS certificate
#   viewer_certificate {
#     acm_certificate_arn      = aws_acm_certificate_validation.website_cert.certificate_arn
#     ssl_support_method       = "sni-only"
#     minimum_protocol_version = "TLSv1.2_2021"
#   }
# }

